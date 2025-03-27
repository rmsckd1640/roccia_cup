package com.roccia.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "ScoreRecord",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"user_id", "sector"})}
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
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private int sector;

    private int score;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt = LocalDateTime.now();

    @PrePersist
    protected void onCreate() {
        this.submittedAt = LocalDateTime.now();
    }
}