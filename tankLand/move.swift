struct MoveAction: PostAction{
    //let action: ActionType
    let action: ActionType
    let distance: Int
    let direction: Direction
    var description: String {
        return "\(action) \(distance) \(direction)"
    }
    
    init(distance: Int, direction: Direction){
        action = .Move
        self.distance = distance
        self.direction = direction
    }
}
extension TankLand {
  func checkLife(gameObject: GameObject) {
    if gameObject.energy <= 0 {
      self[gameObject.position.row, gameObject.position.col] = nil
    }
  }
}

//ethan's also funky move func
func outOfBounds(row: Int, col: Int) -> Bool {
  if ((row > 0 && row < 14) || row == 0 || row == 14) && ((col > 0 && col < 14) || col == 0 || col == 14) {
    return false
  } else {
    return true
  }
}

extension TankLand {
    // Move function for all gameobjects.
    // Takes in an action, will return a bool on the success of that move
  func move(gameObject: GameObject, action : MoveAction? = nil) -> Bool{
    var ogGameObject: GameObject = gameObject
    if gameObject.type == .Tank && action != nil {
      let moveAction: MoveAction = action!

      ogROW = gameObject.position.row // Orginal row
      ogCOL = gameObject.position.col // Orginal col
  
      nextROW += (DirectionToVectorMove[moveAction.direction]!.0 * moveAction.distance + ogROW)
      nextCOL += (DirectionToVectorMove[moveAction.direction]!.1 * moveAction.distance + ogCOL)

      //checks if new coor is out of bounds
        if outOfBounds(row: nextROW, col: nextCOL) == true {
          print("\(gameObject.id): Cannot move because it's out of bounds")
        } else {
          //checks if there's already a GO in the new coor
          if let occupyingGO = self[nextROW, nextCOL] {
            //if it's a tank, tank will not move
            if occupyingGO.type == .Tank {
              print("Cannot move becase there is a tank in the spot")
            //if it's a mine, tank will move and take dmg  
            } else if occupyingGO.type == .Mine {
              self[nextROW, nextCOL] = gameObject
              self[ogROW, ogCOL] = nil
              gameObject.setPosition(Position(nextROW, nextCOL))
              let damageTaken = occupyingGO.energy * Constants.mineStrikeMultiple + Constants.costOfMovingTankPerUnitDistance[moveAction.distance]
              gameObject.chargeEnergy(damageTaken)
              print("\(gameObject.id) moved to \(nextROW),\(nextCOL) and took \(damageTaken) damage")
              checkLife(gameObject: gameObject)
            } else {
              ()
            }
          } else { 
            self[ogROW, ogCOL] = nil
            self[nextROW, nextCOL] = gameObject
            gameObject.setPosition(Position(nextROW, nextCOL))
            print("\(gameObject.id) moved to \(nextROW),\(nextCOL)")
          }
        }
      ogCOL = 0
      ogROW = 0
      nextCOL = 0
      nextROW = 0
    } else if gameObject.type == .Rover {
        ogROW = gameObject.position.row // Orginal row
        ogCOL = gameObject.position.col // Orginal col

        let rover = gameObject as! Rover

        nextROW += (DirectionToVectorMove[rover.mineAction.moveDirection ?? .North]!.0 + ogROW)
        nextCOL += (DirectionToVectorMove[rover.mineAction.moveDirection ?? .North]!.1 + ogCOL)

        //checks if new coor is out of bounds
        if outOfBounds(row: nextROW, col: nextCOL) == true {
            print("Cannot move because it's out of bounds")
        } else {
            //checks if there's already a GO in the new coor
            if let occupyingGO = self[nextROW, nextCOL] {
                //if it's a tank
                if occupyingGO.type == .Tank {
                    occupyingGO.chargeEnergy(gameObject.energy * Constants.mineStrikeMultiple)
                    self[ogROW, ogCOL] = nil
                    print("\(gameObject.id) hit a tank and died")
                    checkLife(gameObject: occupyingGO)
                    if self[nextROW, nextCOL] == nil {
                      print("\(occupyingGO.id) died")
                    }
                //if it's a mine/rover
                    } else if occupyingGO.type == .Mine || occupyingGO.type == .Rover { // Ask Mr.P if we rovers can explode other rovers
                    occupyingGO.chargeEnergy(gameObject.energy * Constants.mineStrikeMultiple)
                    self[ogROW, ogCOL] = nil
                    print("\(gameObject.id) hit a mine/rover and died")
                    checkLife(gameObject: occupyingGO)
                    if self[nextROW, nextCOL] == nil {
                      print("\(occupyingGO.id) died")
                    }
                }
            } else { 
                self[ogROW, ogCOL] = nil
                self[nextROW, nextCOL] = gameObject
                gameObject.setPosition(Position(nextROW, nextCOL))
                print("\(gameObject.id) moved to \(nextROW),\(nextCOL)")
            }
        }
        ogCOL = 0
        ogROW = 0
        nextCOL = 0
        nextROW = 0
        }
    return false
  }
}


//kevin's funky move func

// extension TankLand {
// 	func move(gameObject: GameObject, moveAction: MoveAction, isRover: Bool = false) {
// 		if isRover == false {
// 			var position = gameObject.position
// 			let row = position.row
// 			let col = position.col

// 			var direction = moveAction.direction
// 			let distance = moveAction.distance
			
// 			if let moveAmount = DirectionToVectorMove[direction] * (distance, distance) {
// 				// do adding here
// 			} 

// 		}
// 		else{
// 			// Then it is a rover
// 			let rover = gameObject as! Rover
// 			if isRover != nil {
// 				let position = gameObject.position
// 				let row = position.row
// 				let col = position.col

// 				if let direction = rover.mineAction.moveDirection {
// 					if let moveAmount = DirectionToVectorMove[direction] {
// 						let addRow = moveAmount.0
// 						let addCol = moveAmount.1
// 						let newRow = row + addRow
// 						let newCol = col + addCol
// 						print(newRow, newCol) 
// 					}
// 				}
// 				// Fix here
						
// 			} else {
// 				// Raise an error
// 				print("Not a rover")
// 			}
// 		}
// 	}
// }
