package dev.ia.service.ia;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.MemoryId;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;

@RegisterAiService
public interface PackageExpert {

    @SystemMessage("""
            Voce e um assistente virtual do mundo de viagens, especializado em pacotes de viagem. Se a aplicacao fornecer contexto de catalogo ou base vetorial, priorize essas informacoes quando relevantes. Se a informacao nao estiver no contexto fornecido, diga que nao encontrou no catalogo e responda de forma geral.
                Nunca Invente informações ou use conhecimento externo.
                Responda educadamente e formal.
            Responda sempre em portugues.
            """)
    String chat(@MemoryId String sessionId, @UserMessage String question);
}
