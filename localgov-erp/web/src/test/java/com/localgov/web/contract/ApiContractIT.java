package com.localgov.web.contract;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.localgov.web.testing.ContractTest;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Tag("contract")
@TestPropertySource(properties = {
        "jwt.secret=Q2hhbmdlVGhpc1RvQVN0cm9uZ0FuZExvbmdlckRldk9ubHlTZWNyZXRLZXlGb3JMb2NhbEdvdkVSUA==",
        "jwt.expiration-millis=3600000",
        "spring.datasource.url=jdbc:h2:mem:erp_contract;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.flyway.enabled=false",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect"
})
class ApiContractIT implements ContractTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void unauthorizedErrorContractShapeIsStable() throws Exception {
        String response = mockMvc.perform(get("/employees"))
                .andExpect(status().isUnauthorized())
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode json = objectMapper.readTree(response);
        assertThat(json.hasNonNull("timestamp")).isTrue();
        assertThat(json.path("status").asInt()).isEqualTo(401);
        assertThat(json.path("error").asText()).isEqualTo("Unauthorized");
        assertThat(json.path("code").asText()).isNotBlank();
        assertThat(json.path("message").asText()).isNotBlank();
        assertThat(json.path("path").asText()).isEqualTo("/employees");
    }

    @Test
    void loginResponseContractContainsExpectedFields() throws Exception {
        String body = """
                {
                  "username": "admin",
                  "password": "Admin@123"
                }
                """;

        String response = mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode json = objectMapper.readTree(response);
        assertThat(json.path("token").asText()).isNotBlank();
        assertThat(json.path("tokenType").asText()).isEqualTo("Bearer");
        assertThat(json.path("expiresInMillis").asLong()).isGreaterThan(0L);
        assertThat(json.path("username").asText()).isEqualTo("admin");
        assertThat(json.path("roles").isArray()).isTrue();
    }
}
