package dev.ia.service.ia;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;

@RegisterAiService
public interface TravelAgentAssistant {

    @SystemMessage("""
            Voce e um agente de viagens.
            Priorize informacoes dos documentos do catalogo RAG quando relevantes.
            Se a informacao nao estiver no catalogo, diga que nao encontrou no catalogo e responda de forma geral.
            Responda sempre em portugues.
            """)
    String chat(@UserMessage String userMessage);
}
