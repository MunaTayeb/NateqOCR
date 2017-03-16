//
//  ViewController.swift
//  Nateq-OCR-interface
//
//  Created by Maha on 3/12/17.
//  Copyright © 2017 Maha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate{


     @IBOutlet weak var studioButton: UIButton!
     @IBOutlet weak var capturButton: UIButton!
     @IBOutlet weak var infoButton: UIButton!
    
    
     @IBOutlet weak var textInsideThePopUp: UILabel!
     @IBOutlet weak var popUpWindowForOCRText: UIView!
     @IBOutlet weak var pickedImage: UIImageView!
     let googleAPIKey = "AIzaSyC0gA9lgcdKGKa95nSuOIzxgVn1aqpB4vg"
    
    //choosing image from studio
    @IBAction func fromStudio(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){ let imagePiker = UIImagePickerController()
            imagePiker.delegate = self
            imagePiker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePiker.allowsEditing = false
            self.present(imagePiker, animated: true, completion: nil)
            
        }
        
    }
    
    //capturing image by camera
    @IBAction func fomCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
        
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
   
    
   
    
    @IBAction func showManual(_ sender: Any) {
    }
    @IBAction func showSittings(_ sender: Any) {
        if let settingsURL = URL(string:"prefs:root=General&path=Keyboard/KEYBOARDS") {
            UIApplication.shared.openURL(settingsURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickedImage.isHidden = true
        popUpWindowForOCRText.isHidden = true
        
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        print("=== Pikecd Image ===")
        pickedImage.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
    //------------------------------------------------------------------------------\\
    //Code from the Japanese toturial to use the Google OCR on the ###pickedImage###
    //-------------------------------------------------------------------------------\\
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selected = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 選択した画像をUIImageViewに表示する際にアスペクト比を維持する
        pickedImage.contentMode = UIViewContentMode.scaleAspectFit
        pickedImage.image = selected
        // カメラロール非表示
        dismiss(animated: true, completion: nil)
        // Vision APIを使う
        detectTextGoogle()
    }
    
    
    ///////////////////////
    
    func detectTextGoogle() {
        
        print("=== send to Google ===")
        
        // should be in a timer to repeat every 5 seconds maybe
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,"جاري التحميل");
        
        print("=== after Voive Over ===")
        
        // 画像はbase64する
        // 仮にPNGのみ対象
        let imagedata = UIImagePNGRepresentation(pickedImage.image!)
        let  base64image = imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
       
            // リクエストの作成
            // 文字検出をしたいのでtypeにはTEXT_DETECTIONを指定する
            // 画像サイズの制限があるので本当は大きすぎたらリサイズしたりする必要がある
            let request: Parameters = [
                "requests": [
                    "image": [
                        "content": base64image
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION",
                            "maxResults": 1
                        ]
                    ],
                    "imageContext":[
                        "languageHints": ["ar"]
                    ]
                ]]
            // Google Cloud PlatformのAPI Managerでキーを制限している場合、リクエストヘッダのX-Ios-Bundle-Identifierに指定した値を入れる
            let httpHeader: HTTPHeaders = [
                "Content-Type": "application/json",
                "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
            ]
            // googleApiKeyにGoogle Cloud PlatformのAPI Managerで取得したAPIキーを入れる
            Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)", method: .post, parameters: request, encoding: JSONEncoding.default, headers: httpHeader).validate().responseJSON { response in
                
                  print("=== Before Responce ===")
                // レスポンスの処理
                self.googleResult(response: response)
                
                }.responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                    print("Response Desc: \(response.result.description)")
                    
                    var statusCode = response.response?.statusCode
                    if let error = response.result.error as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            print("Invalid URL: \(url) - \(error.localizedDescription)")
                        case .parameterEncodingFailed(let reason):
                            print("Parameter encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        case .multipartEncodingFailed(let reason):
                            print("Multipart encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        case .responseValidationFailed(let reason):
                            print("Response validation failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            
                            switch reason {
                            case .dataFileNil, .dataFileReadFailed:
                                print("Downloaded file could not be read")
                            case .missingContentType(let acceptableContentTypes):
                                print("Content Type Missing: \(acceptableContentTypes)")
                            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                            case .unacceptableStatusCode(let code):
                                print("Response status code was unacceptable: \(code)")
                                statusCode = code
                            }
                        case .responseSerializationFailed(let reason):
                            print("Response serialization failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            // statusCode = 3840 ???? maybe..
                        }
                        
                        print("Underlying error: \(error.underlyingError)")
                    } else if let error = response.result.error as? URLError {
                        print("URLError occurred: \(error)")
                    } else {
                        print("Unknown error: \(response.result.error)")
                    }

        }
    }
    
    var detectedText: String = ""
    
    func googleResult(response: DataResponse<Any>) {
        print("=== After Responce ===")

        guard let result = response.result.value else {
          print("=== No Text ===")
            return
        }
        let json = JSON(result)
        let annotations: JSON = json["responses"][0]["textAnnotations"]
        
        // 結果からdescriptionを取り出して一つの文字列にする
        
       
        
        var counter = 0
        print("=== befor ===")
        annotations.forEach { (_, annotation) in
            print("text: "+annotation["description"].string!)
            
            if counter == 0 {
                print("=== inside if ===")
                detectedText = annotation["description"].string!
                print("=== detectedText === " + detectedText)
                print("=== inside if ===")
            }
            counter += 1
        }
        print("=== after ===")
        
        
        // 結果を表示する
        print(detectedText)
        //trigger a text to be read by voiceOver
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,detectedText);
        
        
        
        //pop up window
        textInsideThePopUp.text = " "
        self.view.addSubview(popUpWindowForOCRText)
        popUpWindowForOCRText.isHidden = false
        infoButton.isHidden = true
        capturButton.isHidden = true
        studioButton.isHidden = true
        textInsideThePopUp.textAlignment = .center
        textInsideThePopUp.text = detectedText
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,"انقر على النص لإعادة القراءة");
       
        
    }
    @IBAction func popUpClose(_ sender: Any) {
        self.popUpWindowForOCRText.isHidden = true
        infoButton.isHidden = false
        capturButton.isHidden = false
        studioButton.isHidden = false
    }
    
}






