import UIKit

class TripsViewController: UIViewController, UITableViewDataSource {

    let cellId = "tripCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    let fakeData = [
        ("1638 3rd St > 568 Brannan St", "1:50pm-2:05pm (15min)"),
        ("1481 3rd St > 1639 3rd St", "1:37pm-2:05pm (3min)"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: UIImage(named: "navbar"))
        
        tableView.dataSource = self
    }
    
    // MARK: on/off switch 
    
    @IBAction func onOffToggled(sender: UISwitch) {
        if sender.on {
            TripMonitor.sharedMonitor().enableMonitoring()
        } else {
            TripMonitor.sharedMonitor().disableMonitoring()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        assert(numberOfRowsInSection == 0)
        return fakeData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        assert(tableView == self.tableView)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UITableViewCell
        
        // Apparently need this for the separator to work in ios 8
        cell.preservesSuperviewLayoutMargins = false
        // TODO: it still doesn't actually work though
        
        let data = fakeData[indexPath.row]
        
        cell.textLabel?.text = data.0
        cell.detailTextLabel?.text = data.1
        
        return cell
    }

}

