package com.github.anthony_o.testcontainers_proxy_issue;

import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.images.builder.ImageFromDockerfile;
import org.testcontainers.junit.jupiter.Container;

import java.nio.file.Path;

// Inspired by https://www.baeldung.com/spring-dynamicpropertysource#an-alternative-test-fixtures
public class OpenldapTestContainerIntegrationTestExtension implements BeforeAllCallback, AfterAllCallback {
    private static final Logger LOG = LoggerFactory.getLogger(OpenldapTestContainerIntegrationTestExtension.class);

    protected static final int OPENLDAP_EXPOSED_PORT = 1389;

    @Container
    protected GenericContainer<?> openldapContainer;

    @Override
    public void beforeAll(ExtensionContext context) {
        final var imageFromDockerfile = new ImageFromDockerfile()
                .withFileFromPath(".", Path.of("src", "main", "docker"));
        final String dockerImagePrefixEnvVariable = System.getenv("DOCKER_IMAGE_PREFIX");
        // Add argument builder
        imageFromDockerfile.withBuildArg("DOCKER_IMAGE_PREFIX", dockerImagePrefixEnvVariable);
        openldapContainer = new GenericContainer<>(imageFromDockerfile)
                .withExposedPorts(OPENLDAP_EXPOSED_PORT)
                .withLogConsumer(new Slf4jLogConsumer(LOG))
                .waitingFor(Wait.forLogMessage(".*slapd starting.*", 1));

        openldapContainer.start();

        String openldapUrl = String.format("ldap://%s:%s", openldapContainer.getHost(), openldapContainer.getMappedPort(OPENLDAP_EXPOSED_PORT));
        System.setProperty("spring.ldap.urls", openldapUrl);
    }

    @Override
    public void afterAll(ExtensionContext context) {
        // do nothing, Testcontainers handles container shutdown
    }
}
