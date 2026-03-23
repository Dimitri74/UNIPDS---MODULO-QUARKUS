package dev.ia.service.ia;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;

@RegisterAiService
public interface TravelAgentAssistant {

    @SystemMessage("""
            Voce e um agente de viagens.
            Se a aplicacao fornecer contexto de catalogo ou base vetorial, priorize essas informacoes quando relevantes.
            Se a informacao nao estiver no contexto fornecido, diga que nao encontrou no catalogo e responda de forma geral.
            Responda sempre em portugues.
            """)
    String chat(@UserMessage String userMessage);
}
