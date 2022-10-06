package com.github.anthony_o.testcontainers_proxy_issue.repository;

import com.github.anthony_o.testcontainers_proxy_issue.domain.User;
import org.springframework.data.ldap.repository.LdapRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends LdapRepository<User> {
}
