//
//  SampleViewController.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit

class SampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func next(_ sender: Any) {
        guard let addTodo = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo) else { return }
        addTodo.setupAddOptions(.perDayAddTodo)
        addTodo.presentWithAnimation(from: self)
    }
    
    @IBAction func nextPerJourney(_ sender: Any) {
        guard let addTodo = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo) else { return }
        addTodo.setupAddOptions(.perJourneyAddTodo)
        addTodo.presentWithAnimation(from: self)
    }
    
    @IBAction func nextAddJourney(_ sender: Any) {
        guard let addTodo = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo) else { return }
        addTodo.setupAddOptions(.addJourney)
        addTodo.presentWithAnimation(from: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
