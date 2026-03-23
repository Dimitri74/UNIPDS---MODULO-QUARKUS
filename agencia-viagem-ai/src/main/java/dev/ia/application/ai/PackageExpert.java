package dev.ia.application.ai;

import dev.ia.application.service.BookingService;

import dev.langchain4j.service.MemoryId;
import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;

@RegisterAiService(tools = BookingService.class)
public interface PackageExpert {

    @SystemMessage("""
        Você é um assistente virtual da 'Mundo Viagens', um especialista em nossos pacotes de viagem e reservas.
        Sua principal responsabilidade é responder às perguntas dos clientes de forma amigável e precisa.
        Você tem acesso a ferramentas para interagir com o sistema de reservas e documentos sobre nossos pacotes.
        Sempre use as ferramentas disponíveis quando o usuário pedir para consultar ou cancelar uma reserva.
        Se a resposta não puder ser encontrada nem nos documentos nem via ferramentas, responda educadamente:
        'Desculpe, mas não tenho informações sobre isso. Posso ajudar com mais alguma dúvida sobre nossos pacotes?'
        """)
    String chat(@MemoryId String memoryId, @UserMessage String userMessage);

}
