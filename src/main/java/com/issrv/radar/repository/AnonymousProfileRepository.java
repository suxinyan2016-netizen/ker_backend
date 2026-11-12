package com.issrv.radar.repository;

import com.issrv.radar.entity.AnonymousProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AnonymousProfileRepository extends JpaRepository<AnonymousProfile, Integer> {

    Optional<AnonymousProfile> findByDeviceToken(String deviceToken);

    boolean existsByDeviceToken(String deviceToken);

    @Query("select p.deviceToken from AnonymousProfile p")
    List<String> findAllTokens();

    @Query("select distinct p.deviceToken from AnonymousProfile p, AnonymousProfileTag t "
            + "where t.profileId = p.id and t.tagName = :tag")
    List<String> findTokensByTag(@Param("tag") String tag);
}
