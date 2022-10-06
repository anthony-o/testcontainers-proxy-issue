package com.github.anthony_o.testcontainers_proxy_issue.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.springframework.ldap.odm.annotations.Attribute;
import org.springframework.ldap.odm.annotations.Entry;
import org.springframework.ldap.odm.annotations.Id;

import javax.naming.Name;

@Getter
@Setter
@ToString
@RequiredArgsConstructor
@Entry(objectClasses = {"shadowAccount", "posixAccount", "inetOrgPerson"}, base = "ou=users")
public class User {
    @Id
    private Name id;

    @Attribute(name = "uid")
    private String uid;
}
