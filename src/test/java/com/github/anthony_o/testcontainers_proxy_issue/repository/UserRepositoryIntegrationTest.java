package com.github.anthony_o.testcontainers_proxy_issue.repository;

import com.github.anthony_o.testcontainers_proxy_issue.OpenldapTestContainerIntegrationTestExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ExtendWith(OpenldapTestContainerIntegrationTestExtension.class)
@Testcontainers
class UserRepositoryIntegrationTest {
    @Autowired
    private UserRepository userRepository;

    @Test
    void findAllTest() {
        assertThat(userRepository.findAll()).hasSize(2);
    }
}
