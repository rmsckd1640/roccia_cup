package com.roccia.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "ScoreRecord",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"user", "sector"})}
)
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScoreRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user", nullable = false)
    private User user;

    private String sector;

    private int score;

    private LocalDateTime submittedAt = LocalDateTime.now();
}
