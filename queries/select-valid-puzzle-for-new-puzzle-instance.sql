-- Should match select-valid-puzzle-for-new-puzzle-instance-fork.sql
select p1.id,
p1.puzzle_id,
p1.name,
p1.link,
p1.permission,
p1.description,
pf.url
from Puzzle as p
join PuzzleInstance as pi on (p.id = pi.instance)
join Puzzle as p1 on (p1.id = pi.original)
left outer JOIN PuzzleFile AS pf ON (pf.puzzle = p1.id and pf.name == 'original')
where p.puzzle_id = :puzzle_id
and p1.status in (
    :ACTIVE,
    :IN_QUEUE,
    :COMPLETED,
    :FROZEN,
    :REBUILD,
    :IN_RENDER_QUEUE,
    :RENDERING
);
