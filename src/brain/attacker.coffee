util = require '../util'
Brain = require '../brain'
ACTION = require '../actions'

class AttackerBrain extends Brain
  constructor: (@team)->
    super()
    @prevacts = []

  update: (unit, near)->
    super unit

    if util.rand 8
      return @prevacts

    acts = [] 

    dir = []
    for k in [-1, 0, 1]
      for i in [-1, 0, 1]
        continue if i is 0 and k is 0
        dir.push [i, k]

    {x, y} = unit.pos
    mx = Math.ceil((x - 0.5) * @team.mapresolution)
    my = Math.ceil((y - 0.5) * @team.mapresolution)
    cd = @team.coredismap[mx + my * @team.mapsize * @team.mapresolution]
    cdr = @team.coredirmap[mx + my * @team.mapsize * @team.mapresolution]
    
    if cdr > 0
      angs = [0, 180, 90, 270]
      ang = (unit.ang + 360) % 360
      if ang is angs[cdr - 1]
        if util.rand(5) is 0  and near unit.pos, 5
          acts.push ACTION.ATTACK.AIM
        else 
          acts.push ACTION.ATTACK.FOWARD
      else
        switch cdr
          when 1 then acts.push ACTION.MOVE.RIGHT
          when 2 then acts.push ACTION.MOVE.LEFT
          when 3 then acts.push ACTION.MOVE.BOTTOM
          when 4 then acts.push ACTION.MOVE.TOP
      
    else if util.rand 8
      mind = cd
      cand = []
      for d in dir
        index = (mx + d[0]) + (my + d[1]) * @team.mapsize * @team.mapresolution
        index2 = (mx + d[0] * 2) + (my + d[1] * 2) * @team.mapsize * @team.mapresolution
        dis = @team.coredismap[index]
        dis2 = @team.coredismap[index2]
        continue if dis < 0
        continue if util.rand(2) and dis2 < 0
        if dis is mind
          cand.push d
        else if dis < mind and dis > 2
          cand = [d]
          mind = dis
  
      if 0 < cand.length < 5
        d = util.randArray cand
        switch d[0]
          when -1 then acts.push ACTION.MOVE.LEFT
          when 1 then acts.push ACTION.MOVE.RIGHT
        switch d[1]
          when -1 then acts.push ACTION.MOVE.TOP
          when 1 then acts.push ACTION.MOVE.BOTTOM
        if near unit.pos, 5
          acts.push ACTION.ATTACK.AIM
      else
        acts.push util.randArray([
          ACTION.MOVE.TOP, 
          ACTION.MOVE.BOTTOM, 
          ACTION.MOVE.LEFT, 
          ACTION.MOVE.RIGHT
        ])
        acts.push ACTION.ATTACK.AIM
    else
      acts.push util.randArray([
        ACTION.MOVE.TOP, 
        ACTION.MOVE.BOTTOM, 
        ACTION.MOVE.LEFT, 
        ACTION.MOVE.RIGHT
      ])
      acts.push ACTION.ATTACK.AIM

    @prevacts = acts

    return acts

module.exports = AttackerBrain