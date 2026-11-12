package com.issrv.radar.repository;

import com.issrv.radar.entity.AnonymousProfileTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

import java.util.List;

public interface AnonymousProfileTagRepository extends JpaRepository<AnonymousProfileTag, Integer> {

    List<AnonymousProfileTag> findByProfileIdOrderById(Integer profileId);

    @Modifying
    void deleteByProfileId(Integer profileId);
}
