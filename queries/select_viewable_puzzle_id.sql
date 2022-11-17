SELECT id AS puzzle, status
FROM Puzzle AS pz
WHERE pz.puzzle_id = :puzzle_id
AND pz.status IN (1, 2, 3, 4, 5, -30) -- ACTIVE, IN_QUEUE, COMPLETED, FROZEN, BUGGY_UNLISTED, MAINTENANCE
AND NOT (
    pz.id IN (SELECT id FROM Puzzle
        WHERE status = 3 -- COMPLETED
        AND puzzle_id = :puzzle_id
        AND strftime('%s', m_date) < strftime('%s', 'now', '-7 hours')
    )
)
;
