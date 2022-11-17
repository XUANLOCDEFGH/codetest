select p1.id,
p1.puzzle_id,
p1.name,
p1.link,
p1.description
from Puzzle as p
join PuzzleInstance as pi on (p.id = pi.instance)
join Puzzle as p1 on (p1.id = pi.original)
where p1.status in (
    :ACTIVE,
    :IN_QUEUE,
    :COMPLETED,
    :FROZEN,
    :REBUILD,
    :IN_RENDER_QUEUE,
    :RENDERING
)
and p1.permission = :PUBLIC
order by random()
limit 1;


