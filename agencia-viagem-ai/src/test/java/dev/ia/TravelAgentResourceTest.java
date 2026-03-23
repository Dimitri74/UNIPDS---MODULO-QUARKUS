package dev.ia;

import dev.ia.service.ia.PackageExpert;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.mockito.Mockito.when;

@QuarkusTest
class TravelAgentResourceTest {

    @InjectMock
    PackageExpert expert;

    @Test
    void shouldAnswerTravelQuestion() {
        when(expert.chat("session-123", "melhor epoca para visitar o japao"))
                .thenReturn("Primavera e outono sao as melhores epocas pelo clima ameno.");

        given()
                .contentType("text/plain")
                .body("melhor epoca para visitar o japao")
                .when()
                .post("/travel")
                .then()
                .statusCode(200)
                .body(is("Primavera e outono sao as melhores epocas pelo clima ameno."));
    }
}

