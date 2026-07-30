package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "erp_authority_master")
public class AuthorityMaster {

    @Id
    @Column(name = "authority_id", nullable = false, length = 40)
    private String authorityId;

    @Column(name = "authority_ref", nullable = false, length = 30)
    private String authorityRef;

    @Column(name = "authority_type", nullable = false, length = 50)
    private String authorityType;

    public String getAuthorityId() {
        return authorityId;
    }

    public void setAuthorityId(String authorityId) {
        this.authorityId = authorityId;
    }

    public String getAuthorityRef() {
        return authorityRef;
    }

    public void setAuthorityRef(String authorityRef) {
        this.authorityRef = authorityRef;
    }

    public String getAuthorityType() {
        return authorityType;
    }

    public void setAuthorityType(String authorityType) {
        this.authorityType = authorityType;
    }
}
