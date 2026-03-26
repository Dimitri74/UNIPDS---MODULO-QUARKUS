package dev.ia.security;


import dev.ia.service.PromptSecurityExpert;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.guardrail.InputGuardrail;
import dev.langchain4j.guardrail.InputGuardrailResult;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class InjectionGuard implements InputGuardrail {

    @Inject
    PromptSecurityExpert securityExpert;

    @Override
    public InputGuardrailResult validate(UserMessage userMessage) {
        if (securityExpert.isAttack(userMessage.singleText())) {
            return failure("Sua mensagem foi bloqueada por conter instruções não permitidas.");
        }
        return success();
    }
}