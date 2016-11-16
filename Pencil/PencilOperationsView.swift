//
//  PencilOperationsView.swift
//  Pencil
//
//  Created by Klaus Rodewig on 13.10.16.
//  Copyright © 2016 Appnö UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)
let shadingThreshold = π/6

class PencilOperationsView: UIImageView {
    
    let pencilTexture: UIColor?
    var 🖼: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        if let image = UIImage(named: "ShadingTexture") {
            pencilTexture = UIColor(patternImage: image)
        } else {
            print("Could not load image")
            pencilTexture = nil
        }
        super.init(coder: aDecoder)
    }

    var eraserColor: UIColor {
        return backgroundColor ?? UIColor.white
    }
    
    func clearCanvas(animated: Bool) {
        NSLog(#function)
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0
            }, completion: { finished in
                self.alpha = 1
                self.image = nil
                self.🖼 = nil
            })
        } else {
            self.image = nil
            self.🖼 = nil
        }
    }
    
    fileprivate func drawingLineWidth(_ context: CGContext?, touch: UITouch) -> CGFloat {
        var theLineWidth: CGFloat = 5.0
        if touch.force > 0 {
            theLineWidth = touch.force * 4.0
        }
        return theLineWidth
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog(#function)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog(#function)
        guard let theFirstTouch = touches.first else { return }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let theContext = UIGraphicsGetCurrentContext()
        🖼?.draw(in: bounds)
        var touches = [UITouch]()
        if let coalescedTouches = event?.coalescedTouches(for: theFirstTouch) {
            touches = coalescedTouches
        } else {
            touches.append(theFirstTouch)
        }
        for theTouch in touches {
            drawStroke(theContext, touch: theTouch)
        }
        🖼 = UIGraphicsGetImageFromCurrentImageContext()
      
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog(#function)
        image = 🖼
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog(#function)
        image = 🖼
    }
    
    fileprivate func drawStroke(_ context: CGContext?, touch: UITouch) {
        NSLog(#function)
        print(touch.altitudeAngle)
        let thePreviousLocation = touch.previousLocation(in: self)
        let theLocation = touch.location(in: self)
        var lineWidth: CGFloat
        if touch.type == .stylus {
            if touch.altitudeAngle < shadingThreshold {
                lineWidth = shadingLineWidth(context, touch: touch)
            } else {
                lineWidth = drawingLineWidth(context, touch: touch)
            }
            pencilTexture?.setStroke()
        } else {
            lineWidth = touch.majorRadius/2
            eraserColor.setStroke()
        }
        context?.setLineWidth(lineWidth)
        context?.setLineCap(.round)
        context?.move(to: CGPoint(x: thePreviousLocation.x, y: thePreviousLocation.y))
        context?.addLine(to: CGPoint(x: theLocation.x, y: theLocation.y))
        context?.strokePath()
    }
    
    fileprivate func shadingLineWidth(_ context: CGContext?, touch: UITouch) -> CGFloat {
        NSLog(#function)
        let thePreviousLocation = touch.previousLocation(in: self)
        let theLocation = touch.location(in: self)
        
        // In welche Richtung zeigt der Stift und in welche Richtung bewegt er sich?
        let thePencilDirection = touch.azimuthUnitVector(in: self)
        let theLineDirection = CGPoint(x: theLocation.x - thePreviousLocation.x, y: theLocation.y - thePreviousLocation.y)
        // Wie groß ist der Winkel zwischen Stift und Bewegung?
        var theAngle = abs(atan2(theLineDirection.y, theLineDirection.x) - atan2(thePencilDirection.dy, thePencilDirection.dx))
        // Normalisierung des Winkels auf einen Wert zwischen 0 und 90°. Etwas anderes interessiert uns nicht.
        if theAngle > π {
            theAngle = 2 * π - theAngle
        }
        if theAngle > π / 2 {
            theAngle = π - theAngle
        }
        var theLineWidth = 80 * (theAngle - 0) / (π / 2 - 0)
        
        let theMinAltitudeAngle: CGFloat = 0.25
        let theMaxAltitudeAngle = shadingThreshold
        let theAltitudeAngle = touch.altitudeAngle < theMinAltitudeAngle ? theMinAltitudeAngle : touch.altitudeAngle
        let theAltitude = 1 - ((theAltitudeAngle - theMinAltitudeAngle) / (theMaxAltitudeAngle - theMinAltitudeAngle))
        theLineWidth = theLineWidth * theAltitude + 5.0
        
        // Farbintensität anhand der Druckstärke des Stiftes bestimmen
        let theNewAlpha = touch.force/5
        context?.setAlpha(theNewAlpha)

        return theLineWidth
    }
}
