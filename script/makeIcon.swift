import Foundation
import Cocoa

let saveIconPath = "wing/Assets.xcassets/AppIcon.appiconset"

let externalIconsProperty = [
    ["name":"Icon-60"           ,"size": 60],
    ["name":"Icon-72"           ,"size": 72],
    ["name":"Icon-72@2x"        ,"size": 144],
    ["name":"Icon-Small-50"     ,"size": 50],
    ["name":"Icon-Small-50@2x"  ,"size": 100],
    ["name":"Icon"              ,"size": 57],
    ["name":"Icon@2x"           ,"size": 114],
    ["name":"iTunesArtwork"     ,"size": 512],
    ["name":"iTunesArtwork@2x"  ,"size": 1024],
]
let iconsProperty = [
    ["name":"Icon-40"           ,"size": 40],
    ["name":"Icon-40@2x"        ,"size": 80],
    ["name":"Icon-40@3x"        ,"size": 120],
    ["name":"Icon-60@2x"        ,"size": 120],
    ["name":"Icon-60@3x"        ,"size": 180],
    ["name":"Icon-76"           ,"size": 76],
    ["name":"Icon-76@2x"        ,"size": 152],
    ["name":"Icon-83.5@2x"      ,"size": 167],
    ["name":"Icon-Small"        ,"size": 29],
    ["name":"Icon-Small@2x"     ,"size": 58],
    ["name":"Icon-Small@3x"     ,"size": 87]
]


func main(){
    for argument in Process.arguments {
        if argument != "makeIcon.swift" {
            makeImage(argument)
        }
    }
    return
}

func makeImage(path:String){
    print("MakeImage Input:  \(path)")
    let fileManager = NSFileManager.defaultManager()
    fileManager.changeCurrentDirectoryPath("..")
    
    let appstorePath = fileManager.currentDirectoryPath+"/appstore"
    let iconPath = fileManager.currentDirectoryPath+"/" + saveIconPath
    if !NSFileManager.defaultManager().fileExistsAtPath(appstorePath) {
        do{
            try NSFileManager.defaultManager().createDirectoryAtPath(appstorePath, withIntermediateDirectories: false, attributes: nil)
        }catch{
            
        }
    }
    
    for prop in externalIconsProperty{
        
        let fileName = prop["name"] as! String
        let size = prop["size"] as! Int
        let image = imageResize(path,newSize:NSSize(width: size,height:size))
        if image != nil {
            let savePath = appstorePath + "/" + fileName + ".png"
            saveImage(image! ,atPath:savePath)
            print("Saved " + savePath)
        }else{
            return
        }
    }
    
    
    for prop in iconsProperty{
        
        let fileName = prop["name"] as! String
        let size = prop["size"] as! Int
        let image = imageResize(path,newSize:NSSize(width: size,height:size))
        if image != nil {
            let savePath = iconPath + "/" + fileName + ".png"
            saveImage(image! ,atPath:savePath)
            print("Saved " + savePath)
        }else{
            return
        }
    }
    
    do{
        
        
        var contentsInfo = [String:AnyObject]()
        var array = [AnyObject]()
        array.append(["idiom" : "iphone","size" : "29x29","scale" : "2x", "filename" : "Icon-Small@2x.png"])
        array.append(["idiom" : "iphone","size" : "29x29","scale" : "3x","filename" : "Icon-Small@3x.png"])
        array.append(["idiom" : "iphone","size" : "40x40","scale" : "2x","filename" : "Icon-40@2x.png"])
        array.append(["idiom" : "iphone","size" : "40x40","scale" : "3x","filename" : "Icon-40@3x.png"])
        array.append(["idiom" : "iphone","size" : "60x60","scale" : "2x","filename" : "Icon-60@2x.png"])
        array.append(["idiom" : "iphone","size" : "60x60","scale" : "3x","filename" : "Icon-60@3x.png"])
        array.append(["idiom" : "ipad","size" : "29x29","scale" : "1x","filename" : "Icon-Small.png"])
        array.append(["idiom" : "ipad","size" : "29x29","scale" : "2x","filename" : "Icon-Small@2x.png"])
        array.append(["idiom" : "ipad","size" : "40x40","scale" : "1x","filename" : "Icon-40.png"])
        array.append(["idiom" : "ipad","size" : "40x40","scale" : "2x","filename" : "Icon-40@2x.png"])
        array.append(["idiom" : "ipad","size" : "76x76","scale" : "1x","filename" : "Icon-76.png"])
        array.append(["idiom" : "ipad","size" : "76x76","scale" : "2x","filename" : "Icon-76@2x.png"])
        array.append(["idiom" : "ipad", "size" : "83.5x83.5","scale" : "2x","filename" : "Icon-83.5@2x.png"])
        contentsInfo["images"] = array
        contentsInfo["info"] = [ "version" : 1,"author" : "RedSea"]
        
        let theJsonData = try NSJSONSerialization.dataWithJSONObject(contentsInfo, options: NSJSONWritingOptions.PrettyPrinted)
        let jsonString = NSString(data: theJsonData, encoding: NSUTF8StringEncoding)
        try jsonString?.writeToFile(iconPath + "/Contents.json", atomically: true, encoding: NSUTF8StringEncoding)
    }catch{
        
    }

   
}


func imageResize(path:String,newSize:NSSize) -> NSImage? {
    let anImage = NSImage(byReferencingFile:path)
    if anImage == nil {
        print("Not Found File...... \(path)")
        return nil
    }
    if !anImage!.valid {
        print("Source File Not Image...")
        return nil
    }
    let newImage = NSImage(size: newSize)
    newImage.lockFocus()
    NSGraphicsContext.currentContext()?.imageInterpolation = NSImageInterpolation.High
    anImage!.drawInRect(NSMakeRect(0, 0, newSize.width, newSize.height))
    newImage.unlockFocus()
    return newImage
}

func saveImage(anImage:NSImage,atPath:String){
    let cgReg = anImage.CGImageForProposedRect(nil, context: nil, hints: nil)
    let newRep = NSBitmapImageRep(CGImage: cgReg!)
    newRep.size = anImage.size
    let pngData = newRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
    pngData?.writeToFile(atPath, atomically: true)
}


main();
