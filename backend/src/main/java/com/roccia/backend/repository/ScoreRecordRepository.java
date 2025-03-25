package com.roccia.backend.repository;

import com.roccia.backend.entity.ScoreRecord;
import com.roccia.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ScoreRecordRepository extends JpaRepository<ScoreRecord, Long> {

    List<ScoreRecord> findByUser(User user);

    Optional<ScoreRecord> findByUserAndSector(User user, int sector);

    void deleteByUser(User user);
}