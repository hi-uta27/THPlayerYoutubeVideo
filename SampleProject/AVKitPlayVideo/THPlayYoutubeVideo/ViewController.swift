//
//  ViewController.swift
//  AVKitPlayVideo
//
//  Created by TaHieu on 8/26/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var testView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoPlayerViewControllerSegue" {
            let vc = segue.destination as! VideoPlayerViewController
            vc.setVideoID(videoID: "KSe4k0WrpjY",
                          thumnailURL: "https://phunugioi.com/wp-content/uploads/2020/11/hinh-anh-meo-de-thuong-dep-nhat.jpg")
        }
    }

    @IBAction func touchUpInsidePlayManagerButton(_ sender: Any) {}
}
