//
//  TouchDrawingVC.swift
//  Created by Hussnain Waris on 15/02/2017.
//  Copyright © 2017 apphouse. All rights reserved.
//
//

import UIKit
import Photos

class TouchDrawingVC: UIViewController,UIGestureRecognizerDelegate{
    
    // MARK: - IBOutlets
    @IBOutlet var touchTrackerView: TouchDrawingView!
    
    @IBOutlet var antiTouchView: UIView!
    @IBOutlet var switchShapesDetection: UISwitch!    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var colorsView: UIView!
    @IBOutlet weak var sizesView: UIView!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var DarkPenButton: UIButton!
    @IBOutlet var cropButton: UIButton!
    @IBOutlet var eraserButton: UIButton!
    @IBOutlet var lightPenButton: UIButton!
    @IBOutlet var pencilButton: UIButton!
    private var pencilTexture = UIColor(patternImage: UIImage(named: "PencilTexture")!)
    static var croppingView = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
    
        //UIView(frame:CGRect(x: 10, y: 10, width: 100, height: 100))
    //var
    //eraser circle size
    static var eraserView = UIView(frame: CGRect(x:10,y:10,width:60,height:60))
   // static var dummyView = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
    var lightPenColor = UIColor.green
    var darkPenColor = UIColor.black
    var croppingColor:UIColor?
    static var touchImage:UIImage?
    var didPan = false
    
    // MARK: - Public Vars
    var photoLibraryPermission: Bool = false
    var tintColor = UIColor(red: (233/255), green: (159/255), blue: (94/255), alpha: 1.0)
    
    //Perfoming segue variables
    var pathURLToSaveSketch: URL!
    var sketchFileName: String = ""
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        //Do whatever you want here
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        touchTrackerView.layer.borderColor = UIColor.gray.cgColor
        //touchTrackerView.layer.borderWidth = 1.0
       touchTrackerView.layer.masksToBounds = true
        
        hideColorAndSizeView()
        containerView.addSubview(TouchDrawingVC.croppingView)
        containerView.addSubview(TouchDrawingVC.eraserView)
        TouchDrawingVC.eraserView.isHidden = true
        TouchDrawingVC.eraserView.backgroundColor = UIColor.cyan
        TouchDrawingVC.croppingView.backgroundColor = UIColor.clear
        TouchDrawingVC.croppingView.isHidden = true
        
        //masking eraser view
        let maskLayer = CAShapeLayer()
        maskLayer.frame = TouchDrawingVC.eraserView.bounds
        maskLayer.path = UIBezierPath(roundedRect: TouchDrawingVC.eraserView.bounds, cornerRadius: 20).cgPath
        TouchDrawingVC.eraserView.layer.mask = maskLayer
        
        switchShapesDetection.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        checkPhotoLibraryPermission()
        DarkPenButton.isSelected = true
    }
    
    func hideColorAndSizeView(){
        //Hiding colors and sizes views.
        colorsView.isHidden = true
        sizesView.isHidden = true
    }
    
    func setToDefaultValues(){
        touchTrackerView.width = 2
        touchTrackerView.drawingColor = UIColor.black
    }
    
    func setEraserAndCropOff(){
        eraserButton.isSelected = false
        cropButton.isSelected = false
        touchTrackerView.doCropping = false
    }
    
    func setPencilLightDarkPenOff(){
        pencilButton.isSelected = false
        DarkPenButton.isSelected = false
        lightPenButton.isSelected = false
        
    }
    
    @IBAction func darkPen(_ sender: Any) {
        
        TouchDrawingVC.eraserView.isHidden = true
        setState(button: DarkPenButton)
        if DarkPenButton.isSelected{
        
            
            if switchShapesDetection.isOn{
                touchTrackerView.detectionFlag = true
            }else{
                touchTrackerView.detectionFlag = false
            }
            
            
            //set eraser and cropping as false
            touchTrackerView.lightPenSelected = false
            touchTrackerView.pencilPenSelected = false
            touchTrackerView.darkPenSelected = true
            touchTrackerView.width = 2
            touchTrackerView.drawingColor = darkPenColor
                //UIColor.black
            setEraserAndCropOff()
            cropButton.isSelected = false
            pencilButton.isSelected = false
            lightPenButton.isSelected = false
            touchTrackerView.isEraser = false
            touchTrackerView.detectionOption = true
            

           // TouchDrawingVC.croppingView.isHidden = true
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }


        }else{
            DarkPenButton.isSelected = true
            touchTrackerView.darkPenSelected = false
            //setToDefaultValues()
            touchTrackerView.width = 2
            
        }
    }
    
    @IBAction func eraserFucntionality(_ sender: Any) {
        setState(button: eraserButton)
        if eraserButton.isSelected{
            
            touchTrackerView.detectionOption = true
            touchTrackerView.isEraser = true
            touchTrackerView.drawingColor = UIColor.white
            touchTrackerView.width = 5
            cropButton.isSelected = false
            touchTrackerView.doCropping = false
            touchTrackerView.pencilPenSelected = false
            touchTrackerView.darkPenSelected = true
            touchTrackerView.lightPenSelected = false
            setPencilLightDarkPenOff()
            hideColorAndSizeView()
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }
            
        }else{
            DarkPenButton.isSelected = true
            touchTrackerView.darkPenSelected = true
            touchTrackerView.isEraser = false
            TouchDrawingVC.eraserView.isHidden = true
            setToDefaultValues()
        }
        
    }
    
    @IBAction func lightPen(_ sender: Any) {
        
        TouchDrawingVC.eraserView.isHidden = true
        setState(button: lightPenButton)
        if lightPenButton.isSelected{
            touchTrackerView.drawingColor = lightPenColor
                //UIColor.black
            touchTrackerView.width = 10
            touchTrackerView.lightPenSelected = true
            touchTrackerView.darkPenSelected = false
            touchTrackerView.pencilPenSelected = false

            //set eraser and cropping as false Also set darkPen and pencil off
            setEraserAndCropOff()
            cropButton.isSelected = false
            pencilButton.isSelected = false
            DarkPenButton.isSelected = false
            sizesView.isHidden = true
            touchTrackerView.isEraser = false
            touchTrackerView.detectionOption = true
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }

        }else{

            DarkPenButton.isSelected = true
            touchTrackerView.darkPenSelected = true
            touchTrackerView.lightPenSelected = false
             //setToDefaultValues()
            touchTrackerView.width = 2

        }
    }
    
    @IBAction func pencilPen(_ sender: Any) {
        
        TouchDrawingVC.eraserView.isHidden = true
        setState(button: pencilButton)
        if pencilButton.isSelected{
        
            setEraserAndCropOff()
            touchTrackerView.isEraser = false
            touchTrackerView.pencilPenSelected = true
            touchTrackerView.lightPenSelected = false
            touchTrackerView.darkPenSelected = false
            cropButton.isSelected = false
            DarkPenButton.isSelected = false
            lightPenButton.isSelected = false
            touchTrackerView.width = 1
            touchTrackerView.drawingColor = pencilTexture
            touchTrackerView.detectionOption = true
            
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }
            //set eraser and cropping as false
            
            hideColorAndSizeView()
        }else{
            DarkPenButton.isSelected = true
            touchTrackerView.darkPenSelected = true
            touchTrackerView.pencilPenSelected = false
            setToDefaultValues()
           
        }
    }
    
    
    //MARK:- Navigation bar buttons actions.
    @IBAction func goBackToPreviousScreen(_ sender: UIButton) {
        
        //self.dismiss(animated: false, completion: nil)
        //let pathURL = FileManager.default.getURLForStringPath(folderName: "Books/Book 1/Chapter 1/Unnamed Note 1.anb")
        
        /*if pathURLToSaveSketch != nil {
            let imageToSave =  touchTrackerView.getSnapshotImage()
            
            if let image = imageToSave {
                if let data = UIImagePNGRepresentation(image) /*UIImageJPEGRepresentation(image, 1.0)*/ {
                    let imageFilePath = pathURLToSaveSketch.appendingPathComponent(sketchFileName).appendingPathExtension("png")
                    try? data.write(to: imageFilePath)
                    self.dismiss(animated: false, completion: nil)
                } else {
                    print("Image is not saved.")
                }
            } else {
                print("Image is not saved.")
            }
        } else {
            self.dismiss(animated: false, completion: nil)
        }*/
        
        
    }
    
    @IBAction func colorsPanelViewAction(_ sender: UIButton) {
        
        if colorsView.isHidden {
            
            if pencilButton.isSelected || eraserButton.isSelected || cropButton.isSelected{
                colorsView.isHidden = true
            }else{
                colorsView.isHidden = false

            }
            //touchTrackerView.drawingColor = UIColor.black
            sizesView.isHidden = true
            ///setEraserAndCropOff()
            //pencilButton.isSelected = false
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }

        } else {
            colorsView.isHidden = true
        }
    }
    
    @IBAction func sizesPanelViewAction(_ sender: UIButton) {
        
        if sizesView.isHidden {
            
            if lightPenButton.isSelected || pencilButton.isSelected || cropButton.isSelected{
                sizesView.isHidden = true
            }else{
                sizesView.isHidden = false
            }
            colorsView.isHidden = true
            //cropButton.isSelected = false
            //pencilButton.isSelected = false
            touchTrackerView.doCropping = false
            //lightPenButton.isSelected = false
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }

        } else {
            sizesView.isHidden = true
        }
    }
    
    

    @IBAction func cropShapeLayer(_ sender: Any) {
        
        TouchDrawingVC.eraserView.isHidden = true
        setState(button: cropButton)
        if cropButton.isSelected{
            
            touchTrackerView.width = 2.0
            //touchTrackerView.mainShapeLayer.strokeColor = UIColor.magenta.cgColor
            //touchTrackerView.drawingColor = UIColor.magenta
            eraserButton.isSelected = false
            touchTrackerView.isEraser = false
            hideColorAndSizeView()
            setPencilLightDarkPenOff()
            touchTrackerView.doCropping = true
          
          //Adding moving gesture on cropView
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(rec:)))
            TouchDrawingVC.croppingView.addGestureRecognizer(gesture)
            //TouchDrawingVC.dummyView.addGestureRecognizer(gesture)
            //panningCheck()

            
        }else{
            DarkPenButton.isSelected = true
            touchTrackerView.darkPenSelected = true
            
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }
                //TouchDrawingVC.croppingView.isHidden = true
            touchTrackerView.doCropping = false
            setToDefaultValues()
        }
        
    }
    

    //for Panning View in drawingview
    func panGestureAction(rec: UIPanGestureRecognizer){
        print("gesture state is entered")
        let transPoint = rec.translation(in: touchTrackerView)
        //touchTrackerView.superview)
        let x = (rec.view!.center.x) + transPoint.x
        let y = (rec.view!.center.y) + transPoint.y
       // let dumx = TouchDrawingVC.dummyView.center.x + transPoint.x
       // let dumy = TouchDrawingVC.dummyView.center.y + transPoint.y
        rec.view!.center = CGPoint(x: x, y: y)
        rec.setTranslation(CGPoint(x: 0, y: 0), in:touchTrackerView)
            //touchTrackerView.superview)
        
       // TouchDrawingVC.dummyView.center = CGPoint(x: dumx, y: dumy)
    
        //distinguish state
        switch rec.state {
        case .began:
            print("began")
        case .changed:
            //didPan = true
            print("changed")
        case .ended:
            doCropPanning()
            
            
        default:
            print("???")
        }
        
    }
   
    func doCropPanning(){
        let frame = TouchDrawingVC.croppingView.frame
        print("frame",frame)
        
        let image = UIImage(cgImage: (TouchDrawingVC.touchImage?.cgImage)!, scale: (TouchDrawingVC.touchImage?.scale)!, orientation: .up)
        
        //adding image as calyer
        
        let nImage = image.processGrayToWhite(in: image)
        let imageLayer = CALayer()
        imageLayer.contents = nImage?.cgImage
        //image.cgImage
        imageLayer.frame = TouchDrawingVC.croppingView.frame
        
        //TouchDrawingVC.croppingView.layer.borderColor = UIColor.white.cgColor
        touchTrackerView.layer.addSublayer(imageLayer)
        touchTrackerView.currentShapeArray.append(imageLayer)
        TouchDrawingVC.croppingView.layer.sublayers = nil
        TouchDrawingVC.croppingView.isHidden = true
    }
    
    //Redo drawing on view
    @IBAction func redoRecentDrawing(_ sender: Any) {
       
        if TouchDrawingVC.croppingView.isHidden == false{
            doCropPanning()
        }
        
        touchTrackerView.layer.sublayers = nil
        
        if touchTrackerView.redoShapeArray.count > 0 {
            if let last = touchTrackerView.redoShapeArray.last{
                touchTrackerView.currentShapeArray.append(last)
                touchTrackerView.redoShapeArray.removeLast()
            }
            
        }
        
        for layer in touchTrackerView.currentShapeArray{
            if layer === CAShapeLayer(){
                touchTrackerView.layer.addSublayer(layer as! CAShapeLayer)
            }else{
                touchTrackerView.layer.addSublayer(layer as! CALayer)
            }
            //
        }
       
        touchTrackerView.setNeedsDisplay()
        
    }
    
    @IBAction func undoRecentDrawing(_ sender: Any) {
        
        if TouchDrawingVC.croppingView.isHidden == false{
            doCropPanning()
        }
        //print("Array count",touchTrackerView.currentShapeArray.count)
        
        touchTrackerView.layer.sublayers = nil
       
         if touchTrackerView.currentShapeArray.count > 0{
           
            if let last = touchTrackerView.currentShapeArray.last{
                touchTrackerView.redoShapeArray.append(last)
            }
            touchTrackerView.currentShapeArray.removeLast()
        }
        
        touchTrackerView.clearCircleDrawView()
        for layer in touchTrackerView.currentShapeArray{
            
            if layer === CAShapeLayer(){
                touchTrackerView.layer.addSublayer(layer as! CAShapeLayer)
            }else{
                touchTrackerView.layer.addSublayer(layer as! CALayer)
            }
        
        }
        touchTrackerView.setNeedsDisplay()
    }
    
    
     var counter = 0
    var rotation:CGFloat = 0.0
    var scaleX:CGFloat = 1
    var scaleY:CGFloat = 1
    
    @IBAction func rotateDrawingView(_ sender: Any) {
        
        rotation += CGFloat(M_PI_2);
        if TouchDrawingVC.croppingView.isHidden == false{
            doCropPanning()
        }
       
        
        counter += 1
        if counter % 2 == 0 {
            scaleX = 1;
            scaleY = 1;
        }else{
            scaleX = 0.65
            scaleY = 0.65
        }
        
       UIView.animate(withDuration: 0.5, animations: { () -> Void in
       // self.containerView.transform = self.containerView.transform.rotated(by:CGFloat(M_PI_2)
        
        let rotate = CGAffineTransform(rotationAngle: CGFloat(self.rotation))
        let stretchAndRotate = rotate.scaledBy(x: self.scaleX, y: self.scaleY)
        self.containerView.transform = stretchAndRotate
        
        })
        //self.containerView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        
    }
    
    
    //setting stroke width
    @IBAction func setWidth2(_ sender: Any) {
        touchTrackerView.width = 2
    }
    
    @IBAction func setWidth3(_ sender: Any) {
        touchTrackerView.width = 3
    }
    
    @IBAction func setWidth4(_ sender: Any) {
        touchTrackerView.width = 4
    }
    
    @IBAction func setWidth5(_ sender: Any) {
        touchTrackerView.width = 5
    }
    
    @IBAction func setWidth6(_ sender: Any) {
        touchTrackerView.width = 6
    }
    
    //setting color of stroke
    @IBAction func setColorRed(_ sender: Any) {
        touchTrackerView.drawingColor = UIColor.red
        if DarkPenButton.isSelected{
            darkPenColor = UIColor.red
        }
        if lightPenButton.isSelected{
            lightPenColor = UIColor.red
        }
    }
    
    @IBAction func setColorBlue(_ sender: Any) {
        touchTrackerView.drawingColor = UIColor.blue
        if DarkPenButton.isSelected{
            darkPenColor = UIColor.blue
        }
        if lightPenButton.isSelected{
            lightPenColor = UIColor.blue
        }

    }
    
    @IBAction func setColorGreen(_ sender: Any) {
        touchTrackerView.drawingColor = UIColor.green
        if DarkPenButton.isSelected{
            darkPenColor = UIColor.green
        }
        if lightPenButton.isSelected{
            lightPenColor = UIColor.green
        }
    }
    
    @IBAction func setStrokeColorBlack(_ sender: Any) {
        touchTrackerView.drawingColor = UIColor.black
        if DarkPenButton.isSelected{
            darkPenColor = UIColor.black
        }
        if lightPenButton.isSelected{
            lightPenColor = UIColor.black
        }

    }
    
    @IBAction func setStrokeColorYellow(_ sender: Any) {
        touchTrackerView.drawingColor = UIColor.yellow
        if DarkPenButton.isSelected{
            darkPenColor = UIColor.yellow
        }
        if lightPenButton.isSelected{
            lightPenColor = UIColor.yellow
        }
    }
    
    
    func setState(button: UIButton) {
        button.isSelected = !button.isSelected
    }
    
    
    @IBAction func saveImage(_ sender: UIButton) {
        let imageToSave =  touchTrackerView.getSnapshotImage()
        
        let imageCapture = imageToSave
        UIImageWriteToSavedPhotosAlbum((image: imageCapture!), nil, nil, nil)
        
    }
    
    @IBAction func SwitchDetection(_ sender: UISwitch) {
        if switchShapesDetection.isOn{
            touchTrackerView.detectionFlag = true
            touchTrackerView.detectionOption = true
           
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }
            
        }else{
            if TouchDrawingVC.croppingView.isHidden == false{
                doCropPanning()
            }
            touchTrackerView.detectionFlag = false
            if lightPenButton.isSelected || eraserButton.isSelected{
                touchTrackerView.detectionOption = true
            }else{
                touchTrackerView.detectionOption = false

            }
        }
        
    }
    //clear method remove all the bezeir path points from the view
    //draw the view again by setNeedsDisplay
    @IBAction func clearButton(_ sender: UIButton) {
        clear()
    }
    
    func clear(){
        //circleDrawer.clearPath()
        touchTrackerView.clear()
        touchTrackerView.layer.contents = nil
        touchTrackerView.bezierPath.removeAllPoints()
        touchTrackerView.path = nil
        touchTrackerView.layer.sublayers = nil
        
        //flushing all points from Redo and undo Stack
        touchTrackerView.currentShapeArray.removeAll()
        touchTrackerView.redoShapeArray.removeAll()
        
        //removing eraser crop control
        //eraserButton.isSelected = false
        //cropButton.isSelected = false
        hideColorAndSizeView()
        //setPencilLightDarkPenOff()
        ////touchTrackerView.doCropping = false
        //touchTrackerView.lightPenSelected = false
        ////touchTrackerView.isEraser = false
        TouchDrawingVC.eraserView.isHidden = true
        //touchTrackerView.darkPenSelected = false
       // DarkPenButton.isSelected = true
        //panningCheck()
        TouchDrawingVC.croppingView.isHidden = true
        ////setToDefaultValues()

    
    }
    
    //Getting permission to save image into Photo Library or load from it.
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            photoLibraryPermission = true
            break
        //handle authorized status
        case .denied, .restricted:
            photoLibraryPermission = false
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization({ (requestStatus) in
                switch requestStatus {
                case .authorized:
                    self.photoLibraryPermission = true
                    break
                // as above
                case .denied, .restricted:
                    self.photoLibraryPermission = false
                    break
                // as above
                case .notDetermined:
                    self.photoLibraryPermission = false
                    break
                    // won't happen but still
                }
            })
        }
    }
}

//for calculating angle between cgpoints
extension CGPoint {
    func angleToPoint(comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / M_PI)
    }
}


extension UIImage {
    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}



extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}

