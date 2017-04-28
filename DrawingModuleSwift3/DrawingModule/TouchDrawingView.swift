//
//  TouchDrawingView.swift
//  Created by Hussnain Waris on 15/02/2017.
//  Copyright © 2017 apphouse. All rights reserved.
//

import UIKit

class TouchDrawingView: UIView,UIGestureRecognizerDelegate {
    
   
    //For fit circle
    let IterMAX = 8
    //Global setting for drawing width and color
    var drawingColor = UIColor.black
    var guidedColor = UIColor.black.cgColor //Yello hilite color for guided path. UIColor.yellow.cgColor
    var width = 2.0
    var path: CGPath?
    var hullPath:CGPath?
    var hullPoints = [CGPoint]()
    var newhullPoints = [CGPoint]()
    var cropImage:UIImage?
    var cropPath:CGPath?
    var lightPenWidth = 3.0
    var lightPenSelected = false
    var darkPenSelected = false
    var pencilPenSelected = false
    
    var temporaryPath: UIBezierPath?
    
    
    var perPath:CGPath?
    var currentShapeArray = [AnyObject]()
    var redoShapeArray = [AnyObject]()
    let cropShapeLayer = CAShapeLayer()
    let touchController = TouchDrawingVC()
    
    var catMullPath: UIBezierPath?

    var pathIsRectangle = false
    let detectingShapeLayer = CAShapeLayer()
    let nonShapeLayer = CAShapeLayer()

    var bezierPath = UIBezierPath()
    var lightBezeirPath = UIBezierPath()
    var detectionOption = true
    var detectionFlag = true
    
    var checkPointsInTriangle = true
    var checkInside = true
    var checkPoints = false
    var drawDebug = true // set to true show additional information about the fit
    var circleMade = false
    var isRectangle = false
    var checkIn = false
    var isOval = false
    var isTriangle = false
    var TriangleDrawn = false
    var isEraser = false
    var noShape = false
    var doCropping = false
    var lapPerRect = 0.0
    var fitError = 0.0
    var checkRect = 0.0
    var tolerance: CGFloat = 0.2 // circle wiggle room
    var xmax = 0.0
    var xmin = 0.0
    var ymax = 0.0
    var ymin = 0.0
    
    var point1:(x:Double,y:Double) = (0.0,0.0)
    var point2:(x:Double,y:Double) = (0.0,0.0)
    var point3:(x:Double,y:Double) = (0.0,0.0)
    var upwardTriangle = false
    var downTriangle = false
    var minx_miny:(x:Double,y:Double) = (0.0,0.0)
    var maxx_miny:(x:Double,y:Double) = (0.0,0.0)
    var minx_maxy:(x:Double,y:Double) = (0.0,0.0)
    var maxx_maxy:(x:Double,y:Double) = (0.0,0.0)
    var averagePoints:(x:Double,y:Double) = (0.0,0.0)
    
    var mainShapeLayer = CAShapeLayer()
    // MARK: - Private Vars
    fileprivate var fitResult: CircleResult?
    fileprivate var isCircle = false
    fileprivate var bezierPoints = [CGPoint](repeating: CGPoint(), count: 5)
    fileprivate var bezierCounter : Int = 0
    fileprivate var maxPoint = CGPoint.zero
    fileprivate var minPoint = CGPoint.zero
    private var touchedPoints = [CGPoint]()

    
    // MARK: - Public Vars
    //var strokeColor = UIColor.black
    var strokeWidth: CGFloat = 2.0
    var isSigned: Bool = false
    var isDot: Bool = false
    
    var sharpTurn = 0
    var updownDiff = 0
    var leftRightDiff = 0
    var up = 0
    var right = 0
    var down = 0
    var left = 0

    var points: [CGPoint]?

    var temporaryPoints = [CGPoint]()

    
    //new variables
    var current:CGPoint?
    var previousPoint1:CGPoint?
    var previousPoint2:CGPoint?
   
    var cropTouchEnded = false
    
    func midPoint(p1:CGPoint, p2:CGPoint) -> CGPoint
    {
        return CGPoint(x:(p1.x + p2.x) * 0.5,y:(p1.y + p2.y) * 0.5)
    }
    
    
    //updates the fit method with new points
    func updateFit(_ fit: CircleResult?, madeCircle: Bool) {
        fitResult = fit
        isCircle = madeCircle
        setNeedsDisplay()
    }
    
    //Update the cgpath and than reload view using setNeedsDisplay
    func updatePath(_ p: CGPath?) {
        path = p
        perPath = p
        setNeedsDisplay()
    }
    
    // set drawn path to nil
    func clearPath(){
        updatePath(nil)
    }
    
    
    
    
    //Mark: - ClearView
    //This fucntion clear drawn cgpoints from the view
    //these points include cgpoints and shapes layers as well
    
    func clearCircleDrawView() {
        // checkInside = true
        TriangleDrawn = false
        checkPointsInTriangle = true
        checkPoints = false
        circleMade = false
        isRectangle = false
        isTriangle = false
        isOval = false
        updateFit(nil, madeCircle: false)
        bezierPath.removeAllPoints()
        temporaryPath?.removeAllPoints()
        //lightBezeirPath.removeAllPoints()
        hullPoints.removeAll()
        updatePath(nil)
        point1 = (0.0,0.0)
        point2 = (0.0,0.0)
        point3 = (0.0,0.0)
        sharpTurn = 0
        updownDiff = 0
        leftRightDiff = 0
        up = 0
        down = 0
        left = 0
        right = 0
        darkPenPath.removeAllPoints()
        mainShapeLayer.path = nil
        self.layer.addSublayer(mainShapeLayer)
    }
    
    
    
    // MARK: - Initializers
    //intialize the view and set its color, you can do other initialization in this as well
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.backgroundColor = UIColor.gray
        self.backgroundColor = UIColor.clear
        //drawingColor
            //UIColor(patternImage: UIImage(named: "back.jpg")!)

        bezierPath.lineWidth = strokeWidth
        minPoint = CGPoint(x: self.frame.size.width,y: self.frame.size.height)
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.contentsScale = UIScreen.main.scale
        
        
        mainShapeLayer.fillColor = UIColor.clear.cgColor
        mainShapeLayer.shadowRadius = 1.0
        mainShapeLayer.shadowOpacity = 1.0
        mainShapeLayer.shadowColor = drawingColor.cgColor
        mainShapeLayer.shadowOffset = CGSize.zero
        //shapeLayer.shadowPath = perPath
        
        mainShapeLayer.strokeColor = drawingColor.cgColor
        mainShapeLayer.lineJoin = kCALineCapRound
        mainShapeLayer.lineCap = kCALineCapRound
        mainShapeLayer.lineWidth = CGFloat(width) //2.0 //Original value
        self.layer.addSublayer(mainShapeLayer)
        //currentShapeArray.append(shapeLayer)
    }
    
    //intialize the frame
    public override init(frame: CGRect) {
        super.init(frame: frame)
       // self.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        self.backgroundColor = UIColor.clear
        bezierPath.lineWidth = strokeWidth
        minPoint = CGPoint(x: self.frame.size.width,y: self.frame.size.height)
    }
    
    
    // MARK: - Touch Functions
 
    
    var lastPoint:CGPoint?
    let darkPenPath = UIBezierPath()

    //capture cgpoints as first touch on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if let currentPoint = touchPoint(touches) {
           print(currentPoint)
            
            isSigned = true
            temporaryPoints = [currentPoint]
            //temporaryPoints[0] = currentPoint
            
            bezierPoints[0] = currentPoint
            bezierCounter = 0
            clearCircleDrawView()
            redoShapeArray.removeAll()
            lastPoint = currentPoint
            
            if isEraser == true{
            TouchDrawingVC.eraserView.center = currentPoint
            TouchDrawingVC.eraserView.isHidden = false
            }
            
            mainShapeLayer.fillColor = UIColor.clear.cgColor
           
            if doCropping == true{
                mainShapeLayer.strokeColor = UIColor.magenta.cgColor
                mainShapeLayer.fillColor = UIColor.clear.cgColor
                mainShapeLayer.lineWidth = CGFloat(width)
                mainShapeLayer.lineDashPattern = [4,4]
                
                //UIColor.magenta.cgColor
                mainShapeLayer.shadowRadius = 0.0
                mainShapeLayer.shadowOpacity = 0.0
                mainShapeLayer.shadowOffset = CGSize.zero
                
                //setMainShapeShadow()
            }else if lightPenSelected == true{
                mainShapeLayer .lineDashPattern = nil
                mainShapeLayer.lineWidth = CGFloat(width)
                mainShapeLayer.opacity = 0.7
                mainShapeLayer.strokeColor = drawingColor.cgColor
                setMainShapeShadow()
            }else if isEraser == true{
                mainShapeLayer.lineDashPattern = nil
                mainShapeLayer.lineWidth = CGFloat(width*3)
                mainShapeLayer.opacity = 1
                mainShapeLayer.strokeColor = UIColor.white.cgColor
                setMainShapeShadow()
            }else{
                mainShapeLayer .lineDashPattern = nil
                mainShapeLayer.opacity = 1
                mainShapeLayer.lineWidth = CGFloat(width)
                mainShapeLayer.strokeColor = drawingColor.cgColor
                setMainShapeShadow()
            }

            
        }
    }
    
    func setMainShapeShadow(){
        mainShapeLayer.shadowRadius = 1.0
        mainShapeLayer.shadowOpacity = 1.0
        mainShapeLayer.shadowColor = drawingColor.cgColor
        mainShapeLayer.shadowOffset = CGSize.zero

    }
    
 
    
    //capture cgpoints when the user moves the finger to other points continuosly
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let currentPoint = touchPoint(touches) {

            TouchDrawingVC.eraserView.center = currentPoint
            bezierCounter += 1
            checkPoints = true
            //bezierPoints[bezierCounter] = currentPoint
            touchedPoints.append(currentPoint)
            temporaryPoints.append(currentPoint)
            
            
            
            
            //Smoothing is done by Bezier Equations where curves are calculated based on four concurrent  points drawn
           /*if bezierCounter == 4 {
                bezierPoints[3] = CGPoint(x: (bezierPoints[2].x + bezierPoints[4].x) / 2 , y: (bezierPoints[2].y + bezierPoints[4].y) / 2)
               bezierPath.move(to: CGPoint(x:((bezierPoints[0].x)),y:((bezierPoints[0].y))))
               bezierPath.addCurve(to: bezierPoints[3], controlPoint1: bezierPoints[1], controlPoint2: bezierPoints[2])
            
                updatePath(bezierPath.cgPath)
                setNeedsDisplay()
                bezierPoints[0] = bezierPoints[3]
                bezierPoints[1] = bezierPoints[4]
                bezierCounter = 1
                temporaryPath = nil
            }
 */
            
            
            while temporaryPoints.count > 4 {
                temporaryPoints[3] = CGPoint(x:(temporaryPoints[2].x + temporaryPoints[4].x)/2.0,y:(temporaryPoints[2].y + temporaryPoints[4].y)/2.0)
                
                bezierPath.move(to: temporaryPoints[0])
                
                bezierPath.addCurve(to: temporaryPoints[3], controlPoint1: temporaryPoints[1], controlPoint2: temporaryPoints[2])
                updatePath(bezierPath.cgPath)

                temporaryPoints.removeFirst(3)
                temporaryPath = nil
            }
            
            // build temporary path up to last touch point
            
            if temporaryPoints.count == 2 {
                temporaryPath?.move(to: temporaryPoints[0])
                temporaryPath?.addLine(to: temporaryPoints[1])
                if temporaryPath != nil{
                    bezierPath.append((temporaryPath!))
                }
            } else if temporaryPoints.count == 3 {
                temporaryPath?.move(to: temporaryPoints[0])
                temporaryPath?.addQuadCurve(to: temporaryPoints[2], controlPoint: temporaryPoints[1])
                if temporaryPath != nil{
                    bezierPath.append((temporaryPath!))
                }
            } else if temporaryPoints.count == 4 {
                temporaryPath?.move(to: temporaryPoints[0])
                temporaryPath?.addCurve(to: temporaryPoints[3], controlPoint1: temporaryPoints[1], controlPoint2: temporaryPoints[2])
                if temporaryPath != nil{
                    bezierPath.append((temporaryPath!))
                }
            }
            mainShapeLayer.path = bezierPath.cgPath
           // mainShapeLayer.path = bezierPath.cgPath
        }
        
     }
    
  
   


    
   
    //capture cgpoints when user touch ended on the screen
    //this method also check several other conditions like noshapes, triangle lines detection
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if bezierCounter == 0 {
            bezierPath.move(to: bezierPoints[0])
            bezierPath.addLine(to: bezierPoints[0])
            mainShapeLayer.path = bezierPath.cgPath
            setNeedsDisplay()
            isDot = true
        } else {
            mainShapeLayer.path = bezierPath.cgPath
            cropTouchEnded = true

            if isEraser{
                TouchDrawingVC.eraserView.isHidden = true
            }
            
            fitResult = fitCircle(points: touchedPoints)
            bezierCounter = 0
            
            if let location = touchPoint(touches){
                
                bezierPath.addLine(to: location)
                
                updateFit(fitResult, madeCircle:isCircle)
                
                //setting bezeirPath = nil
                //bezierPath.removeAllPoints()
                
                let hasInside = anyPointsInTheMiddle()
                
                checkPointsInTriangle = pointsInsideTriangle()
                
                if let percentOverlap = calculateBoundingOverlap(){
                    print(tolerance)
                    
                    lapPerRect = Double(CGFloat(percentOverlap*100))
                    print("check lapPerRect ",lapPerRect)
                    
                    isCircle = (fitResult?.error)! <= tolerance && !hasInside && lapPerRect >= 85
                    
                    fitError = Double((fitResult?.error)!) * 100
                    print("Fit error is ",fitError)
                    //state = isCircle ? .ended : .failed
                    
                    let hull = closedConvexHull(points_: touchedPoints)
                    
                    var xpoints = [Double]()
                    var ypoints = [Double]()
                    hullPoints = hull
                    
                    for index in touchedPoints{
                        // print("convex hull points",index)
                        xpoints.append(Double(index.x))
                        ypoints.append(Double(index.y))
                    }
                    
                    print("convex hull point count",hull.count)
                    if (xpoints.isEmpty && ypoints.isEmpty)
                    {
                    }else{
                        minx_miny = getMinxMinyPoints(xpoint: xpoints, ypoints: ypoints) as (x:Double,y:Double)
                        maxx_miny = getMaxxMinyPoints(xpoint: xpoints, ypoints: ypoints) as (x: Double, y: Double)
                        maxx_maxy = getMaxxMaxyPoints(xpoint: xpoints, ypoints: ypoints) as (x: Double, y: Double)
                        minx_maxy = getMinxMaxyPoints(xpoint: xpoints, ypoints: ypoints) as (x: Double, y: Double)
                    }
                    
                    minx_miny.x.round()
                    minx_miny.y.round()
                    minx_maxy.x.round()
                    minx_maxy.y.round()
                    maxx_miny.x.round()
                    maxx_miny.y.round()
                    maxx_maxy.x.round()
                    maxx_maxy.y.round()
                    
                    var roundedpoints = [CGPoint]()
                    for touch in touchedPoints{
                        var tox = touch.x
                        var toy = touch.y
                        tox = tox.rounded()
                        //.roundToDecimals(decimals: 1)
                        toy = toy.rounded()
                        // roundToDecimals(decimals: 1)
                        var cg = CGPoint()
                        cg.x = tox
                        cg.y = toy
                        roundedpoints.append(cg)
                    }
        
                    //print(roundedpoints)
                    sharpTurns(points: roundedpoints)
                    
                    compareTrianglePoints(touchPoints: roundedpoints)
                    noShape = NoShapeDetected(touches: roundedpoints)
                    xmax = xpoints.max()!
                    xmin = xpoints.min()!
                    ymax = ypoints.max()!
                    ymin = ypoints.min()!
                    
                    if doCropping{
                        
                        if let path = path{
                            croppingModule(path: path)
                        }
                        
                    }
                    
                }
                
                
                checkRect = lapPerRect
                checkInside = hasInside
                touchedPoints.removeAll(keepingCapacity: true)
                perPath = path
                path = nil
                setNeedsDisplay()
                

            }
        }
        
        drawShapes()

    }

    
    
    //cropping fucntionality here
    func croppingModule(path:CGPath){
        
        cropPath = path
        
        print(path.boundingBoxOfPath)
        let frame = path.boundingBox
        
        if frame.width != 0 && frame.height != 0 {
            // TouchDrawingVC.croppingView.center = path.uiKitCenter()
            //path.boundingBoxOfPath
            
            let _shapeLayer = CAShapeLayer()
            let npath = UIBezierPath()
            npath.move(to: touchedPoints.first!)
            for points in touchedPoints{
                npath.addLine(to: points)
            }
            npath.close()
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
            if let ctx = UIGraphicsGetCurrentContext() {
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(bounds)
            }
            _shapeLayer.path = npath.cgPath
            self.layer.mask = _shapeLayer
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            cropImage = wholeImage
            
            // UIImageWriteToSavedPhotosAlbum((image: cropImage!), nil, nil, nil)
            //  TouchDrawingVC.dummyView.frame = frame
            TouchDrawingVC.croppingView.frame = frame
            //frame
            
            if cropPath != nil{
                
                let rect = cropPath?.boundingBox
                let scale = cropImage?.scale
                let scaledRect = CGRect(x: (rect?.origin.x)! * scale!, y: (rect?.origin.y)! * scale!, width: (rect?.size.width)! * scale!, height: (rect?.size.height)! * scale!)
                let cgImage = cropImage?.cgImage?.cropping(to: scaledRect)
                let image = UIImage(cgImage: cgImage!, scale: scale!, orientation: .up)
                
                let coloredImage = image.processPixels(in: image)
                
                //let nImage = coloredImage?.processGrayToWhite(in: coloredImage!)
                TouchDrawingVC.touchImage = coloredImage
                //nImage
                //UIImageWriteToSavedPhotosAlbum((image: nImage!), nil, nil, nil)
                //coloredImage
                TouchDrawingVC.croppingView.backgroundColor = UIColor(patternImage:coloredImage!)
                //TouchDrawingVC.croppingView.layer.borderWidth = 1.0
                //TouchDrawingVC.croppingView.layer.borderColor = UIColor.red.cgColor
                self.layer.mask = nil
                TouchDrawingVC.croppingView.isHidden = false
                
            }
        }
        
        let shapelayer = CAShapeLayer()
        let newPath = UIBezierPath()
        newPath.move(to: touchedPoints.first!)
        for points in touchedPoints{
            newPath.addLine(to: points)
        }
        newPath.close()
        //UIBezierPath(roundedRect: frame, cornerRadius: 20)
        /// newPath.cgPath = path
        // UIColor.red.setFill()
        newPath.fill()
        newPath.stroke()
        setNeedsDisplay()
        shapelayer.frame = bounds
        shapelayer.path = newPath.cgPath
        shapelayer.fillColor = UIColor.white.cgColor
        //shapelayer.fillRule = kCAFillRuleEvenOdd
        self.layer.addSublayer(shapelayer)
        self.cropShapeLayer.removeFromSuperlayer()
        currentShapeArray.append(shapelayer)
    }



    //checking L V W shapes and any other random shapes
    func NoShapeDetected(touches:[CGPoint]) -> Bool{
        
            let startPoint:CGPoint = touches.first!
            let endPoint: CGPoint = touches.last!
            let xdiff = endPoint.x - startPoint.x
            let ydiff = endPoint.y - startPoint.y
            let ixdiff = startPoint.x - endPoint.x
            let iydiff = startPoint.y - endPoint.y
            print("x diff",xdiff)
            print("y diff",ydiff)
            print("ixdiff",ixdiff)
            print("iydiff",iydiff)
            if xdiff > 60 || ydiff > 60 || ixdiff > 60 || iydiff > 60
            {
                return true
            }else{
                return false
            }
        
    }

    //Logic for detecting the number if lines made by path based on angles calculated
    func sharpTurns(points:[CGPoint]){
        print(points.count,"Array count")
        var checkAngle:[Float] = []
        for i in 1..<points.count{
            checkAngle.append(getAngle(a: points[i-1], b: points[i]))
            //print(arr)
            // print(checkAngle,"")
        }
        checkAngle.append(getAngle(a: points[points.count-1], b: points[0]))
        print(checkAngle.count,"Angle count")
        var angle:[Int] = []
        for index in checkAngle{
            //angle.append(abs(Int(index)))
            angle.append(Int(index))
            //print(index)
        }
        
        for _ in angle{
            //print(index)
        }

        var angle_0 = 0
        var angle_90 = 0
        var angle_ve90 = 0
        var angle_180 = 0
        var angle_45 = 0
        var angle_ve45 = 0
        var angle_135 = 0
        var angle_ve135 = 0
        
        for i in  0..<angle.count{
            if angle[i] >= 75 && angle[i] <= 110{
                angle_90 += 1
            }else if angle[i] >= -15 && angle[i] <= 15{
                angle_0 += 1
            }else if angle[i] >= 165 && angle[i] <= 186{
               
                angle_180 += 1
                
            }
            else if angle[i] >= 30 && angle[i] <= 65{
               
                angle_45 += 1
                sharpTurn += 1
                
            }else if angle[i] >= 125 && angle[i] <= 160{
                
                angle_135 += 1
                sharpTurn += 1
                
            }else if angle[i] >= -100 && angle[i] <= -80{
                
                angle_ve90 += 1
                
            }else if angle[i] >= -65 && angle[i] <= -30{
                
                angle_ve45 += 1
                sharpTurn += 1

            }else if angle[i] >= -165 && angle[i] <= -125{
                
                angle_ve135 += 1
                sharpTurn += 1

            }
        }
        updownDiff = angle_180 - angle_0
        leftRightDiff = angle_ve90 - angle_90
        
        up = angle_180
        down = angle_0
        right = angle_90
        left = angle_ve90
        
        print(sharpTurn,"Sharp turn")
        print(" 180     up",angle_180)
        print(" 0     down",angle_0)
        print(" 90   right",angle_90)
        print("-90   left",angle_ve90)
        print(" 45       ",angle_45)
        print("-45      ",angle_ve45)
        print(" 135      ",angle_135)
        print("-135     ",angle_ve135)
        print("upDownDiff",updownDiff)
        print("lfetright",leftRightDiff)

    }
    
    
    func getAngle(a:CGPoint,b:CGPoint) -> Float{
        let X = b.x - a.x
        let Y = b.y-a.y
        let angleVal:Float = (atan2(Float(X),Float(Y))*180)/Float(M_PI)
        return angleVal
    }
    
    //Getting touch points to use in Touches Moved method
    func touchPoint(_ touches: Set<UITouch>) -> CGPoint? {
        if let touch = touches.first {
            let point = touch.location(in: self)
            //Track the signature bounding area
            if point.x > maxPoint.x {
                maxPoint.x = point.x
                //maxPoint.x = CGFloat(ceil(Double(point.x)))
            }
            if point.y > maxPoint.y {
                maxPoint.y = point.y
                //maxPoint.y = CGFloat(ceil(Double(point.y)))
            }
            if point.x < minPoint.x {
                minPoint.x = point.x
                //minPoint.x = CGFloat(ceil(Double(point.x)))
            }
            if point.y < minPoint.y {
                minPoint.y = point.y
                //minPoint.y = CGFloat(ceil(Double(point.y)))

            }
            return point
        }
        return nil
    }
    
    //Checking points with in the circle or sqaure or rectangle
    
    private func anyPointsInTheMiddle() -> Bool {
        // 1
        let fitInnerRadius = (fitResult?.radius)! / sqrt(2) * tolerance
        // 2
        let innerBox = CGRect(
            x: (fitResult?.center.x)! - fitInnerRadius,
            y: (fitResult?.center.y)! - fitInnerRadius,
            width: 2 * fitInnerRadius,
            height: 2 * fitInnerRadius)
        
        // 3
        var hasInside = false
        for point in touchedPoints {
            if innerBox.contains(point) {
                hasInside = true
                break
            }
        }
        
        return hasInside
    }
    
    //checking any points if lies with in the triangle
    private func pointsInsideTriangle() -> Bool {
        // 1
        let fitInnerRadius = (fitResult?.radius)! / sqrt(2) * tolerance
        // 2
        let innerBox = CGRect(
            x: (fitResult?.center.x)! - fitInnerRadius,
            y: (fitResult?.center.y)! - fitInnerRadius,
            width: 2 * fitInnerRadius-3,
            height: 2 * fitInnerRadius-3)
        
        // 3
        var hasInside = false
        for point in touchedPoints {
            if innerBox.contains(point) {
                hasInside = true
                break
            }
        }
        return hasInside
    }
    
    // calculate the bounding overlap of a rectangle
    
    private func calculateBoundingOverlap() -> CGFloat? {
        // 1
        let fitBoundingBox = CGRect(
            x: (fitResult?.center.x)! - (fitResult?.radius)!,
            y: (fitResult?.center.y)! - (fitResult?.radius)!,
            width: 2 * (fitResult?.radius)!,
            height: 2 * (fitResult?.radius)!)
        
            if let pathBoundingBox = path?.boundingBox
            {
                let overlapRect = fitBoundingBox.intersection(pathBoundingBox)
                let overlapRectArea = overlapRect.width * overlapRect.height
                let circleBoxArea = fitBoundingBox.height * fitBoundingBox.width
                let percentOverlap = overlapRectArea / circleBoxArea
                return percentOverlap
            };return nil
        
    }
    
    func drawShapes(){
        mainShapeLayer.path = nil
        if doCropping{
            
            if let path = path
            {
                cropShapeLayer.path = path
                //cropShapeLayer.opacity = 0.5
                cropShapeLayer.fillColor = UIColor.clear.cgColor
                //let color = UIColor(red: 105, green: 105, blue: 105,alpha:1)
                cropShapeLayer.lineWidth = CGFloat(width)
                cropShapeLayer.lineDashPattern = [4,4]
                cropShapeLayer.strokeColor = UIColor.magenta.cgColor
                //UIColor.red.cgColor
                //cropShapeLayer.lineWidth = CGFloat()
                self.layer.addSublayer(cropShapeLayer)
                
                if cropTouchEnded{
                    //let newShape = CAShapeLayer()
                    currentShapeArray.append(cropShapeLayer)
                    
                }
                cropTouchEnded = false
                
                print("hello")
                //currentshapeArray append
            }
            
        }else{
            
            if isDot {
                
                //drawingColor.setStroke()
                //bezierPath.lineWidth = CGFloat(width)
                //bezierPath.lineCapStyle = CGLineCap.round
                //bezierPath.stroke()
                isDot = false
                
                //print("Dot is true.")
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = bezierPath.cgPath
                // let shapecolor = isCircle ? UIColor.red : UIColor.clear
                //shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = drawingColor.cgColor
                shapeLayer.lineCap = kCALineCapRound
                shapeLayer.lineWidth = CGFloat(width)
                shapeLayer.shadowRadius = 1.0
                shapeLayer.shadowOpacity = 1.0
                shapeLayer.shadowColor = drawingColor.cgColor
                shapeLayer.shadowOffset = CGSize.zero
                // add the new layer to our custom view
                self.layer.addSublayer(shapeLayer)
                currentShapeArray.append(shapeLayer)
                print("crop")
                
            } else {
                
                if detectionOption == true {
                    
                    //drawing a circle here
                    
                    if let fit = fitResult  // if there is a fit and drawDebug is turned on
                    {
                        if !fit.error.isNaN && fitError <= 18 && noShape == false && lightPenSelected == false && pencilPenSelected == false && hullPoints.count >= 12 && isEraser == false && detectionFlag == true && checkRect > 82// if error has been defined, draw the fit
                            
                        {
                            let fitRect = CGRect(
                                x: fit.center.x - fit.radius,
                                y: fit.center.y - fit.radius,
                                width: 2 * fit.radius,
                                height: 2 * fit.radius
                            )
                            
                            let fitPath = UIBezierPath(ovalIn: fitRect)
                            fitPath.lineWidth = CGFloat(width)
                            
                            //adding shape layer
                            //let shapeLayer = CAShapeLayer()
                            let circleshapeLayer = CAShapeLayer()
                            circleshapeLayer.path = fitPath.cgPath
                            //let shapecolor = isCircle ? drawingColor: UIColor.clear
                            circleshapeLayer.fillColor = UIColor.clear.cgColor
                           
                            //circleshapeLayer.strokeColor = shapecolor.cgColor
                            circleshapeLayer.strokeColor = drawingColor.cgColor
                            circleshapeLayer.lineWidth = CGFloat(width)
                            
                            circleshapeLayer.shadowRadius = 1.0
                            circleshapeLayer.shadowOpacity = 1.0
                            circleshapeLayer.shadowColor = drawingColor.cgColor
                            circleshapeLayer.shadowOffset = CGSize.zero
                            // add the new layer to our custom view
                            //detectingShapeLayer.removeFromSuperlayer()
                            self.layer.addSublayer(circleshapeLayer)
                            currentShapeArray.append(circleshapeLayer)
                            circleMade = true
                            print("circle")
                        }
                        
                        //drawing a triangle here and detecting it
                        
                        if circleMade == false && checkPoints == true && checkRect >= 35 && checkRect < 95  && fitError > 12 && fitError < 37 && hullPoints.count > 0 && hullPoints.count <= 22 && isRectangle == false && noShape == false  && lightPenSelected == false && isEraser == false && pencilPenSelected == false && (up < 5 || down < 5 || right < 5 || left < 5) && detectionFlag == true && sharpTurn > 6
                        {
                            let hpath = UIBezierPath()
                            hpath.move(to: CGPoint(x:point1.x,y:point1.y))
                            hpath.addLine(to:CGPoint(x:point2.x,y:point2.y))
                            hpath.addLine(to:CGPoint(x:point3.x,y:point3.y))
                            hpath.addLine(to:CGPoint(x:point1.x,y:point1.y))
                            hpath.close()
                            
                            let shapeLayer = CAShapeLayer()
                            shapeLayer.path = hpath.cgPath
                            shapeLayer.fillColor = UIColor.clear.cgColor
                            shapeLayer.strokeColor = drawingColor.cgColor
                            shapeLayer.lineWidth = CGFloat(width)
                            
                            shapeLayer.shadowRadius = 1.0
                            shapeLayer.shadowOpacity = 1.0
                            shapeLayer.shadowColor = drawingColor.cgColor
                            shapeLayer.shadowOffset = CGSize.zero
                            
                            // add the new layer to our custom view
                            detectingShapeLayer.removeFromSuperlayer()
                            self.layer.addSublayer(shapeLayer)
                            currentShapeArray.append(shapeLayer)
                            
                            isTriangle = true
                            if (point1.x == 0.0 && point1.y == 0.0) || (point2.x == 0.0 && point2.y == 0.0) || (point3.x == 0.0 && point3.y == 0.0 ){
                                TriangleDrawn = false
                            }else{
                                TriangleDrawn = true
                                print("Triangle")
                            }
                            //setNeedsDisplay()
                            
                        }
                        
                        //drawing a rectangle here using path bounding box
                        
                        if circleMade == false && checkPoints == true &&  checkRect <= 85 && checkRect > 35 && checkInside == false  && fitError > 7 && fitError <= 28 && sharpTurn <= 25 /*&& hullPoints.count > 5*/ && hullPoints.count <= 35 && TriangleDrawn == false && noShape == false  && lightPenSelected == false && pencilPenSelected == false && isEraser == false && up >= 5 && down >= 5 && right >= 5 && left >= 5 && detectionFlag == true
                        {
                            if perPath?.boundingBox != nil
                            {
                                let boundingBox = UIBezierPath(rect: (perPath!.boundingBox))
                                boundingBox.lineWidth = CGFloat(width)
                                let shapeLayer = CAShapeLayer()
                                let circleColor = isCircle ? UIColor.clear : drawingColor
                                shapeLayer.path = UIBezierPath(rect: (perPath?.boundingBox)!).cgPath
                                shapeLayer.fillColor = UIColor.clear.cgColor
                                shapeLayer.strokeColor = circleColor.cgColor
                                shapeLayer.lineWidth = CGFloat(width)
                                shapeLayer.shadowRadius = 1.0
                                shapeLayer.shadowOpacity = 1.0
                                shapeLayer.shadowColor = drawingColor.cgColor
                                shapeLayer.shadowOffset = CGSize.zero
                                
                                // add the new layer to our custom view
                                //detectingShapeLayer.removeFromSuperlayer()
                                self.layer.addSublayer(shapeLayer)
                                currentShapeArray.append(shapeLayer)
                                isRectangle = true
                                print("rectangle")
                                
                            }
                        }
                        
                        //drawing and detecting an oval shape here
                        if hullPoints.count >= 14/* && checkInside == false*/ && fitError <= 40 && circleMade == false && /*checkRect >= 35 &&*/ checkRect < 98 && noShape == false  && lightPenSelected == false && pencilPenSelected == false && isRectangle == false && sharpTurn >= 7 && isTriangle == false && isEraser == false && detectionFlag == true
                        {
                            
                            if !fit.error.isNaN
                            { // if error has been defined, draw the fit
                                
                                
                                if (xmax-xmin)>(ymax-ymin){  //horizontal oval
                                    var fity = fit.center.y - fit.radius
                                    if(ymax - ymin) > 50 && ymax-ymin <= 100{   fity += 17  }
                                    else if (ymax-ymin) > 100 && (ymax-ymin) <= 150{ fity += 25}
                                    else if(ymax - ymin) > 150 && (ymax-ymin) <= 200{fity += 30}
                                    else if (ymax-ymin) > 200{fity += 35}
                                    else{fity += 10}
                                    
                                    _ = CGRect(
                                        x: fit.center.x - fit.radius,
                                        y:fity,
                                        //y: fit.center.y - fit.radius,
                                        width: 2 * fit.radius,
                                        height: 2 * fit.radius/1.5 )
                                  
                                    //let fitPath = UIBezierPath(ovalIn: fitRect)
                                    //fitPath.lineWidth = CGFloat(width)
                                    
                                    let horizontalFit = UIBezierPath(ovalIn:(perPath?.boundingBox)!)
                                    horizontalFit.lineWidth = CGFloat(width)
                                    //adding shape layer
                                    let shapeLayer = CAShapeLayer()
                                    
                                    //shapeLayer.path = fitPath.cgPath
                                    shapeLayer.path = horizontalFit.cgPath
                                    
                                    //let shapecolor = isCircle ? UIColor.white : UIColor.clear
                                    shapeLayer.fillColor = UIColor.clear.cgColor
                                    shapeLayer.strokeColor = drawingColor.cgColor
                                    shapeLayer.lineWidth = CGFloat(width)
                                    shapeLayer.shadowRadius = 1.0
                                    shapeLayer.shadowOpacity = 1.0
                                    shapeLayer.shadowColor = drawingColor.cgColor
                                    shapeLayer.shadowOffset = CGSize.zero
                                    //detectingShapeLayer.removeFromSuperlayer()
                                    self.layer.addSublayer(shapeLayer)
                                    currentShapeArray.append(shapeLayer)
                                    
                                    isOval = true
                                    print("oval")
                                }
                                else
                                    //vertical oval drawing and detection
                                {
                                    var fitx = fit.center.x - fit.radius
                                    if (xmax-xmin) > 100 && (xmax-xmin) <= 150  {       fitx += 20    }
                                    else if (xmax-xmin) > 150 && (xmax-xmin) <= 200{    fitx += 25    }
                                    else if (xmax-xmin) > 200 && (xmax - xmin) <= 250{  fitx += 30  }
                                    else if(xmax-xmin) > 250    {   fitx += 35  }
                                    else{   fitx += 15  }
                                    
                                    _ = CGRect(
                                        // x: fit.center.x - fit.radius+10,
                                        x:fitx,
                                        y: fit.center.y - fit.radius,
                                        width: 2 * fit.radius/1.6,
                                        height: 2 * fit.radius
                                    )
                                    //let fitPath = UIBezierPath(ovalIn: fitRect)
                                    //fitPath.lineWidth = CGFloat(width)
                                    
                                    let verticalFit = UIBezierPath(ovalIn:(perPath?.boundingBox)!)
                                    verticalFit.lineWidth = CGFloat(width)
                                    //adding shape layer
                                    let shapeLayer = CAShapeLayer()
                                    shapeLayer.path = verticalFit.cgPath
                                    //let shapecolor = isCircle ? UIColor.white : UIColor.clear
                                    shapeLayer.fillColor = UIColor.clear.cgColor
                                    shapeLayer.strokeColor = drawingColor.cgColor
                                    shapeLayer.lineWidth = CGFloat(width)
                                    shapeLayer.shadowRadius = 1.0
                                    shapeLayer.shadowOpacity = 1.0
                                    shapeLayer.shadowColor = drawingColor.cgColor
                                    shapeLayer.shadowOffset = CGSize.zero
                                    // add the new layer to our custom view
                                    detectingShapeLayer.removeFromSuperlayer()
                                    self.layer.addSublayer(shapeLayer)
                                    currentShapeArray.append(shapeLayer)
                                    isOval = true
                                    print("oval")
                                    
                                }
                            }
                        }
                        
                        
                        
                        //conditions other than above mentioned to draw shapes other than mentioned above
                        if circleMade == false && isOval == false && isRectangle == false && TriangleDrawn == false && checkPoints == true && lightPenSelected == false && pencilPenSelected == false && isEraser == false
                        {
                            //adding shape layer
                            let shapeLayer = CAShapeLayer()
                            // if lightPenSelected == true{
                            //shapeLayer.path = darkPenPath.cgPath
                            //   shapeLayer.opacity = 0.2
                            // }else{
                            //bezierPath.append(temporaryPath!)
                            shapeLayer.path = bezierPath.cgPath
                            
                            
                                //temporaryPath?.cgPath
                                //
                            //perPath
                            //}
                            shapeLayer.lineJoin = kCALineCapRound
                            shapeLayer.lineCap = kCALineCapRound
                            shapeLayer.fillColor = UIColor.clear.cgColor
                            shapeLayer.strokeColor = drawingColor.cgColor
                            shapeLayer.lineWidth = CGFloat(width)
                            shapeLayer.shadowRadius = 1.0
                            shapeLayer.shadowOpacity = 1.0
                            shapeLayer.shadowColor = drawingColor.cgColor
                            shapeLayer.shadowOffset = CGSize.zero
                            //detectingShapeLayer.removeFromSuperlayer()
                            self.layer.addSublayer(shapeLayer)
                            currentShapeArray.append(shapeLayer)
                            print("no shape")
                        }
                        
                        //light pen drawing here
                        if circleMade == false && isOval == false && TriangleDrawn == false && checkPoints == true && isRectangle == false && lightPenSelected == true && pencilPenSelected == false && isEraser == false{
                            
                            drawLightPen(lightPenPath:(bezierPath.cgPath))
                            //catMullPath!.cgPath))
                            
                        }
                        
                        //conditions for pencil pen drawing
                        if circleMade == false && isOval == false && TriangleDrawn == false && checkPoints == true && isRectangle == false && lightPenSelected == false && pencilPenSelected == true && isEraser == false{
                            if perPath != nil{
                                drawPencil(pencilPath: perPath!)
                            }
                        }
                        
                        //eraser pen here
                        if circleMade == false && isOval == false && TriangleDrawn == false && isRectangle == false && checkPoints == true  && lightPenSelected == false && pencilPenSelected == false && isEraser == true{
                            if perPath != nil{
                                drawEraser(eraserPath: perPath!)
                            }
                            
                        }
                        
                        
                    }
                    
                }
                else
                {
                   
                    
                    if  cropTouchEnded{
                        //draw only signature when detection is off
                        // draw a thick yellow line for the user touch path
                        let shapeLayer = CAShapeLayer()
                        shapeLayer.fillColor = UIColor.clear.cgColor
                        shapeLayer.path = bezierPath.cgPath
                        //perPath
                        
                        //shapeLayer.shadowPath = perPath
                        
                        shapeLayer.shadowRadius = 1.0
                        shapeLayer.shadowOpacity = 1.0
                        shapeLayer.shadowColor = drawingColor.cgColor
                        shapeLayer.shadowOffset = CGSize.zero
                        //shapeLayer.shadowPath = perPath
                        
                        shapeLayer.strokeColor = drawingColor.cgColor
                        shapeLayer.lineJoin = kCALineCapRound
                        shapeLayer.lineCap = kCALineCapRound
                        shapeLayer.lineWidth = CGFloat(width) //2.0 //Original value
                       // nonShapeLayer.removeFromSuperlayer()
                        self.layer.addSublayer(shapeLayer)
                        currentShapeArray.append(shapeLayer)
                    }
                   // cropTouchEnded = false
                    
                }
            }
            
        }
        
    }
    
    
    
 /*
    //Draw methods for shapes
    override func draw(_ rect: CGRect) {
  
    }
    */
    
    
    //eraser drawing method
    func drawEraser(eraserPath:CGPath){
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = eraserPath
        shapeLayer.lineJoin = kCALineCapRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.contentsScale = 0.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = drawingColor.cgColor
        shapeLayer.lineWidth = CGFloat(width*3)
        //detectingShapeLayer.removeFromSuperlayer()
        self.layer.addSublayer(shapeLayer)
        currentShapeArray.append(shapeLayer)
    }
    
    //pencil pen drawing method
    func drawPencil(pencilPath:CGPath){
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = pencilPath
        shapeLayer.lineJoin = kCALineCapRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.contentsScale = 0.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = drawingColor.cgColor
        shapeLayer.lineWidth = CGFloat(width)
        //detectingShapeLayer.removeFromSuperlayer()
        self.layer.addSublayer(shapeLayer)
        currentShapeArray.append(shapeLayer)
    }
    
    //lightpen drawing method
    func drawLightPen(lightPenPath:CGPath){
        let shapeLayer = CAShapeLayer()
        //shapeLayer.contentsScale = 0.0
        shapeLayer.path = lightPenPath
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        //shapeLayer.shadowPath = lightPenPath
        
        // shapeLayer.shouldRasterize = true
        //shapeLayer.contentsScale = UIScreen.main.scale
        
        shapeLayer.shadowRadius = 1.0
        shapeLayer.shadowOpacity = 1.0
        shapeLayer.shadowColor = drawingColor.cgColor
        shapeLayer.shadowOffset = CGSize.zero
        
        shapeLayer.opacity = 0.7 //Alpha value for light pen
        shapeLayer.lineJoin = kCALineCapRound
        shapeLayer.lineCap = kCALineCapRound
        //shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = drawingColor.cgColor
        shapeLayer.lineWidth = CGFloat(width)
        //detectingShapeLayer.removeFromSuperlayer()
        self.layer.addSublayer(shapeLayer)
        currentShapeArray.append(shapeLayer)
    }
    
    
    //MARK: Utility Methods
    
    /** Clears the drawn paths in the canvas
     */
    func clear() {
        isSigned = false
        
        bezierPath.removeAllPoints()
        setNeedsDisplay()
        
    }
    
    /** Returns the drawn path as Image. Adding subview to this view will also get returned in this image.
     */
    func getSignatureAsImage() -> UIImage? {
        if isSigned {
            UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let signature: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return signature
        }
        return nil
    }
    
    /** Returns the rect of signature image drawn in the canvas. This can very very useful in croping out the unwanted empty areas in the signature image returned.
     */
    func getSignatureBoundsInCanvas() -> CGRect {
        return CGRect(x: minPoint.x, y: minPoint.y, width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
    }
    
    //Closed convex hull points for Triangle shape
    func closedConvexHull(points_ : [CGPoint]) -> [CGPoint] {
        
        // 2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
        // Returns a positive value, if OAB makes a counter-clockwise turn,
        // negative for clockwise turn, and zero if the points are collinear.
        func cross(P: CGPoint, A: CGPoint, B: CGPoint) -> CGFloat {
            let part1 = (A.x - P.x) * (B.y - P.y)
            let part2 = (A.y - P.y) * (B.x - P.x)
            return  part1 - part2;
        }
        
        // Sort points lexicographically
        let points = points_.sorted {
            if $0.0.y != $0.1.y {
                return $0.0.y > $0.1.y
            } else {
                return $0.0.x < $0.1.x
            }
        }
        // Build the lower hull
        var lower: [CGPoint] = []
        for p in points {
            while lower.count >= 2 && cross(P: lower[lower.count-2], A: lower[lower.count-1], B: p) <= 0 {
                lower.removeLast()
            }
            lower.append(p)
        }
        
        // Build upper hull
        var upper: [CGPoint] = []
        let reversedPoints : [CGPoint] = points.reversed()
        for p in reversedPoints {
            while upper.count >= 2 && cross(P: upper[upper.count-2], A: upper[upper.count-1], B: p) <= 0 {
                upper.removeLast()
            }
            upper.append(p)
        }
        
        // Last point of upper list is omitted because it is repeated at the
        // beginning of the lower list.
        upper.removeLast()
        
        // Concatenation of the lower and upper hulls gives the convex hull.
        return (upper + lower)
    }
    
    // this fucntion is core logic of triangle drawing
    //check condition of upward downward rightward and leftward triangle
    
    func compareTrianglePoints(touchPoints:[CGPoint]) {
        var xTouch = [Double]()
        var yTouch = [Double]()
        
        for index in touchPoints{
            
            xTouch.append(Double(index.x))
            yTouch.append(Double(index.y))
            
            // let minX = minx_miny.x
            //let maxX = maxx_maxy.x
            //let minY = minx_miny.y
            //let maxY = maxx_maxy.y
            
            if index.equalTo(CGPoint(x:minx_miny.x,y:minx_miny.y)) {
                
                point1.x = minx_miny.x
                point1.y = minx_miny.y
                var iterx = minx_miny.x
                var itery = minx_miny.y
                
                
                
                var pointUpdated = false
                while itery <= minx_maxy.y{
                    for point in touchedPoints{
                        if Double(point.y.rounded()) == itery{
                            if Double(point.x) >= maxx_miny.x - 5{
                                //print("minx miny",minx_miny.x,"minx miny",minx_miny.y)
                                print("point 3 x",point.x)
                                point2.x = Double(point.x)
                                point2.y = itery
                                pointUpdated = true
                                break
                            }
                        }
                    }
                    if pointUpdated == true{
                        break
                    }
                    
                    itery += 1
                }
                
                
                
                pointUpdated = false
                while iterx <= maxx_miny.x{
                    
                    for point in touchedPoints{
                        
                        if Double(point.x.rounded()) == iterx{
                            //print("point2 x",point.x)
                            if Double(point.y) >= maxx_maxy.y - 5{
                                point3.x = iterx
                                point3.y = Double(point.y)
                                pointUpdated = true
                                break
                            }
                            
                        }
                    }
                    if pointUpdated == true {
                        break
                    }
                    
                    iterx += 1
                }
                
                print("min x min y are the starting point")
                
                
                isTriangle = true
                
                //maxmimum X minimum Y
            }else
                if index.equalTo(CGPoint(x:maxx_miny.x,y:maxx_miny.y)) {
                    
                    point1.x = maxx_miny.x
                    point1.y = maxx_miny.y
                    
                    var iterx = maxx_miny.x
                    var itery = maxx_miny.y
                    
                    
                    var pointUpdated = false
                    while iterx >= minx_miny.x{
                        
                        for point in touchedPoints{
                            
                            if Double(point.x.rounded()) == iterx{
                                //print("point2 x",point.x)
                                if Double(point.y) >= maxx_maxy.y - 5{
                                    point2.x = iterx
                                    point2.y = Double(point.y)
                                    pointUpdated = true
                                    break
                                }
                                
                            }
                        }
                        if pointUpdated == true {
                            break
                        }
                        
                        iterx -= 1
                    }
                    
                    
                    pointUpdated = false
                    while itery <= minx_maxy.y{
                        for point in touchedPoints{
                            if Double(point.y.rounded()) == itery{
                                if Double(point.x) <= minx_miny.x + 5{
                                    //print("minx miny",minx_miny.x,"minx miny",minx_miny.y)
                                    print("point 3 x",point.x)
                                    point3.x = Double(point.x)
                                    point3.y = itery
                                    pointUpdated = true
                                    break
                                }
                            }
                        }
                        if pointUpdated == true{
                            break
                        }
                        
                        itery += 1
                    }
                    
                    
                    
                    isTriangle = true
                    
                    print("max x min y are the starting point")
                    //minimum X maximum Y
                }else if index.equalTo(CGPoint(x:minx_maxy.x,y:minx_maxy.y)) {
                    
                    
                    point1.x = minx_maxy.x
                    point1.y = minx_maxy.y
                    
                    var iterx = minx_maxy.x
                    var itery = minx_maxy.y
                    
                    
                    while  iterx <= maxx_maxy.x{
                        
                        for point in touchedPoints{
                            
                            if Double(point.x.rounded()) == iterx{
                                // print("point2 y",point.y)
                                if Double(point.y) <= minx_miny.y + 5{
                                    point2.x = iterx
                                    point2.y = Double(point.y)
                                }
                            }
                        }
                        iterx += 1
                        
                    }
                    
                    var pointUpdated = false
                    while itery >= minx_miny.y{
                        for point in touchedPoints{
                            if Double(point.y.rounded()) == itery{
                                if Double(point.x) >= maxx_maxy.x - 5{
                                    //print("minx miny",minx_miny.x,"minx miny",minx_miny.y)
                                    print("point 3 x",point.x)
                                    point3.x = Double(point.x)
                                    point3.y = itery
                                    pointUpdated = true
                                    break
                                }
                            }
                        }
                        if pointUpdated == true{
                            break
                        }
                        
                        itery -= 1
                    }
                    
                    print("min_x max_y are the starting points")
                    isTriangle = true
                    // maximum X maximum Y
                }else if index.equalTo(CGPoint(x:maxx_maxy.x,y:maxx_maxy.y)){
                    
                    point1.x = maxx_maxy.x
                    point1.y = maxx_maxy.y
                    var iterx = maxx_maxy.x
                    var itery = maxx_maxy.y
                    
                    
                    
                    var pointUpdated = false
                    while iterx >= minx_maxy.x{
                        
                        for point in touchedPoints{
                            if Double(point.x.rounded()) == iterx{
                                //print("point2 x",point.x)
                                if Double(point.y) <= minx_miny.y + 5{
                                    point2.x = iterx
                                    point2.y = Double(point.y)
                                    pointUpdated = true
                                    break
                                }
                                
                            }
                        }
                        if pointUpdated == true {
                            break
                        }
                        
                        iterx -= 1
                    }
                    
                    
                    pointUpdated = false
                    while itery >= minx_miny.y{
                        for point in touchedPoints{
                            if Double(point.y.rounded()) == itery{
                                if Double(point.x) <= minx_miny.x + 5{
                                    //print("minx miny",minx_miny.x,"minx miny",minx_miny.y)
                                    print("point 3 x",point.x)
                                    point3.x = Double(point.x)
                                    point3.y = itery
                                    pointUpdated = true
                                    break
                                }
                            }
                        }
                        if pointUpdated == true{
                            break
                        }
                        
                        itery -= 1
                    }
                    print("max_x max_y are the starting point")
                    
                    isTriangle = true
                    
            }
            
        }
        
    }
    
    //return minimum x points and maxmimum y points from drawn points array
    func getMinxMinyPoints(xpoint:[Double],ypoints:[Double]) -> (Double,Double){
        
        let minx = xpoint.min()
        let miny = ypoints.min()
        return (minx!,miny!)
    }
    
    
    //return maximum x points and minimum y points from drawn points array
    
    func getMaxxMinyPoints(xpoint:[Double],ypoints:[Double]) -> (Double,Double){
        
        let maxx = xpoint.max()
        let miny = ypoints.min()
        return (maxx!,miny!)
        
    }
    
    //return minimum x points and maximum y points from drawn points array
    
    func getMinxMaxyPoints(xpoint:[Double],ypoints:[Double]) -> (Double,Double){
        
        let minx = xpoint.min()
        let maxy = ypoints.max()
        return (minx!,maxy!)
        
    }
    
    //return maximum x points and maximum y points from drawn points array
    
    func getMaxxMaxyPoints(xpoint:[Double],ypoints:[Double]) -> (Double,Double){
        
        let maxx = xpoint.max()
        let maxy = ypoints.max()
        return (maxx!,maxy!)
        
    }
    
}

//used for rounding values of double and cgfloats
extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension UIView{
    public func getSnapshotImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        UIColor.white.setFill()
        UIRectFill(self.bounds)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshotImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapshotImage
    }
   
    func snapshot(of rect: CGRect?) -> UIImage? {
        // snapshot entire view
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        // otherwise, grab specified `rect` of image
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    func cropScreen(rect:CGRect) -> UIImage?{
    
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        if let snapshotImage: UIImage = UIGraphicsGetImageFromCurrentImageContext(){
            let imageRef = snapshotImage.cgImage?.cropping(to: rect)
            let image = UIImage(cgImage: imageRef!)
            UIGraphicsEndImageContext()

            return image

        }else{
         return nil
        }
    
    }
   
}

extension CGPath {
    
    func uiKitCenter() ->CGPoint {
        let layer = CAShapeLayer()
        layer.path = self
        return  CGPoint(x: layer.frame.midX, y: layer.frame.midY)
        
    }
}


extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func processPixels(in image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                if pixelBuffer[offset] == .white {
                    pixelBuffer[offset] = .clear
                }
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }
    
    func processGrayToWhite(in image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                //magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
                
                /*if pixelBuffer[offset].redComponent >= 120 && pixelBuffer[offset].redComponent <= 250 && pixelBuffer[offset].blueComponent >= 120 && pixelBuffer[offset].blueComponent <= 250 && pixelBuffer[offset].greenComponent >= 120 && pixelBuffer[offset].greenComponent <= 250 */
                    if pixelBuffer[offset].blueComponent >= 175 && pixelBuffer[offset].blueComponent <= 255 && pixelBuffer[offset].redComponent <= 255 && pixelBuffer[offset].redComponent >= 175 && pixelBuffer[offset].greenComponent <= 180{
                    pixelBuffer[offset] = .clear
                }
                
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }

}


struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    static let clear   = RGBA32(red: 0,   green: 0, blue: 0, alpha: 0)
    static let gray    = RGBA32(red: 127, green: 127, blue: 127, alpha: 255)
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}

extension UIColor {
    
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

extension UIBezierPath {
    
    convenience init?(hermiteInterpolatedPoints points: [CGPoint], closed: Bool) {
        self.init()
        
        guard points.count > 1 else { return nil }
        
        let numberOfCurves = closed ? points.count : points.count - 1
        
        var previousPoint: CGPoint? = closed ? points.last : nil
        var currentPoint:  CGPoint  = points[0]
        var nextPoint:     CGPoint? = points[1]
        
        move(to: currentPoint)
        
        for index in 0 ..< numberOfCurves {
            let endPt = nextPoint!
            
            var mx: CGFloat
            var my: CGFloat
            
            if previousPoint != nil {
                mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x)*0.5
                my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y)*0.5
            } else {
                mx = (nextPoint!.x - currentPoint.x) * 0.5
                my = (nextPoint!.y - currentPoint.y) * 0.5
            }
            
            let ctrlPt1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
            
            previousPoint = currentPoint
            currentPoint = nextPoint!
            let nextIndex = index + 2
            if closed {
                nextPoint = points[nextIndex % points.count]
            } else {
                nextPoint = nextIndex < points.count ? points[nextIndex % points.count] : nil
            }
            
            if nextPoint != nil {
                mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x) * 0.5
                my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y) * 0.5
            }
            else {
                mx = (currentPoint.x - previousPoint!.x) * 0.5
                my = (currentPoint.y - previousPoint!.y) * 0.5
            }
            
            let ctrlPt2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
            
            addCurve(to: endPt, controlPoint1: ctrlPt1, controlPoint2: ctrlPt2)
        }
        
        if closed { close() }
    }
    
    /// Create smooth UIBezierPath using Catmull-Rom Splines
    ///
    /// This requires at least four points.
    ///
    /// Adapted from https://github.com/jnfisher/ios-curve-interpolation
    /// See http://spin.atomicobject.com/2014/05/28/ios-interpolating-points/
    ///
    /// - parameter catmullRomInterpolatedPoints: The array of CGPoint values.
    /// - parameter closed:                       Whether the path should be closed or not
    /// - parameter alpha:                        The alpha factor to be applied to Catmull-Rom spline.
    ///
    /// - returns:  An initialized `UIBezierPath`, or `nil` if an object could not be created for some reason (e.g. not enough points).
    
    convenience init?(catmullRomInterpolatedPoints points: [CGPoint], closed: Bool, alpha: Float) {
        self.init()
        
        guard points.count > 3 else { return nil }
        
        assert(alpha >= 0 && alpha <= 1.0, "Alpha must be between 0 and 1")
        
        let endIndex = closed ? points.count : points.count - 2
        
        let startIndex = closed ? 0 : 1
        
        let kEPSILON: Float = 1.0e-5
        
        move(to: points[startIndex])
        
        for index in startIndex ..< endIndex {
            let nextIndex = (index + 1) % points.count
            let nextNextIndex = (nextIndex + 1) % points.count
            let previousIndex = index < 1 ? points.count - 1 : index - 1
            
            let point0 = points[previousIndex]
            let point1 = points[index]
            let point2 = points[nextIndex]
            let point3 = points[nextNextIndex]
            
            let d1 = hypot(Float(point1.x - point0.x), Float(point1.y - point0.y))
            let d2 = hypot(Float(point2.x - point1.x), Float(point2.y - point1.y))
            let d3 = hypot(Float(point3.x - point2.x), Float(point3.y - point2.y))
            
            let d1a2 = powf(d1, alpha * 2)
            let d1a  = powf(d1, alpha)
            let d2a2 = powf(d2, alpha * 2)
            let d2a  = powf(d2, alpha)
            let d3a2 = powf(d3, alpha * 2)
            let d3a  = powf(d3, alpha)
            
            var controlPoint1: CGPoint, controlPoint2: CGPoint
            
            if fabs(d1) < kEPSILON {
                controlPoint1 = point2
            } else {
                
                controlPoint1 = (point2 * d1a2 - point0 * d2a2 + point1 * (2 * d1a2 + 3 * d1a * d2a + d2a2)) / (3 * d1a * (d1a + d2a))
            }
            
            if fabs(d3) < kEPSILON {
                controlPoint2 = point2
            } else {
                controlPoint2 = (point1 * d3a2 - point3 * d2a2 + point2 * (2 * d3a2 + 3 * d3a * d2a + d2a2)) / (3 * d3a * (d3a + d2a))
            }
            
            addCurve(to: point2, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        if closed { close() }
    }
    
    
}

private func * (lhs: CGPoint, rhs: Float) -> CGPoint {
    return CGPoint(x: lhs.x * CGFloat(rhs), y: lhs.y * CGFloat(rhs))
}

private func / (lhs: CGPoint, rhs: Float) -> CGPoint {
    return CGPoint(x: lhs.x / CGFloat(rhs), y: lhs.y / CGFloat(rhs))
}

private func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

private func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}


