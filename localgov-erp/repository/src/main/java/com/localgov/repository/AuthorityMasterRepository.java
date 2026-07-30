package com.localgov.repository;

import com.localgov.domain.model.AuthorityMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AuthorityMasterRepository extends JpaRepository<AuthorityMaster, String> {
    Optional<AuthorityMaster> findByAuthorityRef(String authorityRef);

    @Query(value = """
            SELECT DISTINCT a.authority_type
            FROM erp_authority_master a
            WHERE LOWER(COALESCE(a.status, 'active')) = 'active'
            ORDER BY a.authority_type
            """, nativeQuery = true)
    List<String> findDistinctAuthorityTypes();

    @Query(value = """
            SELECT p.province_code AS provinceCode,
                   p.province_name AS provinceName
            FROM erp_province p
            ORDER BY p.province_name
            """, nativeQuery = true)
    List<ProvinceRow> findAllProvinces();

    @Query(value = """
            WITH ranked AS (
                SELECT a.authority_id AS authorityId,
                       a.authority_ref AS authorityRef,
                       a.province_code AS provinceCode,
                       p.province_name AS provinceName,
                       a.official_name AS districtName,
                       a.authority_type AS authorityType,
                       ROW_NUMBER() OVER (ORDER BY p.province_name, a.official_name) AS authorityNumber
                FROM erp_authority_master a
                JOIN erp_province p ON p.province_code = a.province_code
                WHERE LOWER(COALESCE(a.status, 'active')) = 'active'
            )
            SELECT authorityId,
                   authorityRef,
                   provinceCode,
                   provinceName,
                   districtName,
                   authorityType,
                   authorityNumber
            FROM ranked
            WHERE (:provinceCode IS NULL OR provinceCode = :provinceCode)
            ORDER BY provinceName, districtName
            """, nativeQuery = true)
    List<DistrictRow> findDistrictsByProvince(@Param("provinceCode") String provinceCode);

    interface ProvinceRow {
        String getProvinceCode();

        String getProvinceName();
    }

    interface DistrictRow {
        String getAuthorityId();

        String getAuthorityRef();

        String getProvinceCode();

        String getProvinceName();

        String getDistrictName();

        String getAuthorityType();

        Long getAuthorityNumber();
    }
}
