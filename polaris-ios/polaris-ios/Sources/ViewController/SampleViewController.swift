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
        addTodo.modalPresentationStyle = .overFullScreen
        addTodo.setupAddOptions(.perDayAddTodo)
        self.present(addTodo, animated: false, completion: nil)
    }
    
    @IBAction func nextPerJourney(_ sender: Any) {
        guard let addTodo = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo) else { return }
        addTodo.modalPresentationStyle = .overFullScreen
        addTodo.setupAddOptions(.perJourneyAddTodo)
        self.present(addTodo, animated: false, completion: nil)
    }
    
    @IBAction func nextAddJourney(_ sender: Any) {
        guard let addTodo = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo) else { return }
        addTodo.modalPresentationStyle = .overFullScreen
        addTodo.setupAddOptions(.addJourney)
        self.present(addTodo, animated: false, completion: nil)
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
