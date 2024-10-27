package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"os"
	"os/signal"
	"strconv"
	"sync"
	"syscall"
	"time"

	"github.com/segmentio/kafka-go"
)

type Event struct {
	UserID    int       `json:"user_id"`
	EventType string    `json:"event_type"`
	Timestamp time.Time `json:"timestamp"`
	UserType  string    `json:"user_type"`
	Location  string    `json:"location"`
}

func main() {
	enabledEnv := os.Getenv("PRODUCER_ENABLED")

	if enabledEnv == "" {
		panic("A variável de ambiente PRODUCER_ENABLED não está definida.")
	}

	if enabledEnv != "true" {
		log.Println("O produtor está desativado.")
		return
	}

	kafkaProducerHost := os.Getenv("KAFKA_BROKERS")

	if kafkaProducerHost == "" {
		panic("A variável de ambiente KAFKA_BROKERS não está definida.")
	}

	log.Printf("Conectando ao Kafka em %s...\n", kafkaProducerHost)
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{kafkaProducerHost},
		Topic:    "user_events",
		Balancer: &kafka.LeastBytes{},
	})

	eventTypes := []string{"Login", "Logout", "Download", "Share"}
	userTypes := []string{"Free", "Premium", "Enterprise"}
	locations := []string{"US", "BR", "EU", "IN"}

	rpmStr := os.Getenv("PRODUCER_RPM")
	if rpmStr == "" {
		panic("A variável de ambiente PRODUCER_RPM não está definida.")
	}

	rpm, err := strconv.Atoi(rpmStr)
	if err != nil {
		log.Fatalf("Erro ao converter PRODUCER_RPM: %v", err)
		panic(err)
	}

	log.Printf("Iniciando produtor com %d RPM...\n", rpm)
	interval := 60.0 / float64(rpm)

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		defer wg.Done()
		for {
			select {
			case <-signalChan:
				log.Println("Recebido sinal de interrupção, fechando o writer...")
				writer.Close()
				return
			default:
				event := Event{
					UserID:    rand.Intn(100),
					EventType: eventTypes[rand.Intn(len(eventTypes))],
					Timestamp: time.Now(),
					UserType:  userTypes[rand.Intn(len(userTypes))],
					Location:  locations[rand.Intn(len(locations))],
				}

				eventData, err := json.Marshal(event)
				if err != nil {
					log.Fatalf("Falha ao serializar o evento: %v", err)
				}

				msg := kafka.Message{
					Key:   []byte(fmt.Sprintf("%d", event.UserID)),
					Value: eventData,
				}

				err = writer.WriteMessages(context.Background(), msg)
				if err != nil {
					log.Fatalf("Falha ao enviar mensagem: %v", err)
				}

				fmt.Printf("Evento enviado: %v\n", event)

				time.Sleep(time.Duration(interval * float64(time.Second)))
			}
		}
	}()

	wg.Wait()
}
