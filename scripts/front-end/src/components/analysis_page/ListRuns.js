import React from 'react';
import { Redirect } from 'react-router-dom';

import { confirmAlert } from 'react-confirm-alert';
import '../../css/react-confirm-alert.css';

class ListRuns extends React.Component {
    // constructor will only be called once
    constructor(props) {
        super(props);
        this.state = {
            data: this.props.data,
            redrecit: false,
        };

        // bind functions
        this.CreatList = this.CreatList.bind(this);
        this.getColorByStatus = this.getColorByStatus.bind(this);
        this.confirmToDelete = this.confirmToDelete.bind(this);
    };


    // update data when props changed
    componentWillReceiveProps(nextProps) {
        this.setState({
            data: nextProps.data
        })
    }


    // function to set color of status
    getColorByStatus(the_status) {
        var the_color = 'blue';

        switch (String(the_status)) {
            case "Completed": the_color = 'blue'; break;
            case "Running": the_color = 'green'; break;
            case "Failed": the_color = 'red'; break;
            default: the_color = 'blue';
        }
        return the_color
    }


    // ask user to confirm deletion
    confirmToDelete(the_run_id) {
        confirmAlert({
            title: 'Confirm to delete',
            message: 'Are you sure to delete the run?',
            buttons: [
                {
                    label: 'Yes',
                    onClick: () => this.props.onDeleteRunClicked(the_run_id)
                },
                {
                    label: 'No',
                    onClick: () => { }
                }
            ]
        });
    }

    CreatList() {
        return (
            <table className="ui single line table">
                <thead>
                    <tr>
                        <th>Run Name</th>
                        <th>User</th>
                        <th>Submit Date</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {
                        this.state.data.map(item => {
                            return (
                                <tr key={item._id}>
                                    <td> {item.name} </td>
                                    <td> {item.username} </td>
                                    <td> {item.start_date}</td>
                                    <td style={{ color: this.getColorByStatus(item.status) }}>
                                        {item.status}
                                    </td>
                                    <td>
                                        <button className="ui basic green button"
                                            onClick={() => this.props.onMenuClicked('jobDetail_page', item)}
                                        >
                                            See Details</button>
                                        <button className="ui basic red button"
                                            onClick={() => this.confirmToDelete(item._id)}
                                        >
                                            Delete</button>
                                    </td>
                                </tr>
                            )
                        })
                    }
                </tbody>
            </table>
        )
    };

    render() {
        if (this.state.redirect) {
            return <Redirect to={{
                pathname: '/analysis/job_detail',
                state: {
                    data: this.state.result_from_server
                }
            }} />
        }

        return (
            <div >
                <div className="ui container">
                    <div className="ui compact success message"
                        style={{ display: this.props.filters_applied ? 'block' : 'none' }}>
                        <p>Filters applied</p>
                    </div>
                </div>
                {this.CreatList()}
            </div>
        )
    }
};


export default ListRuns;

