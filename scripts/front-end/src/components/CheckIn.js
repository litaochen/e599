import React from 'react';
import TestServerConnection from '../apis/TestServerConnection';

class CheckIn extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            // temp store of user name, avoid frequently updating cookies
            user_name: this.props.user_name,
            server_connected: false,
            // 0 means not checked in, 1 means checked in
            checkedIn: this.props.user_name === "" ? false : true
        }

        // bind method
        this.showCheckinForm = this.showCheckinForm.bind(this);
        this.afterSuccessCheckin = this.afterSuccessCheckin.bind(this);
        this.onReCheckIn = this.onReCheckIn.bind(this);
        this.onCheckIn = this.onCheckIn.bind(this);
        this.onUserNameChanged = this.onUserNameChanged.bind(this);
    };


    // connect to server on loaded
    async componentDidMount() {
        const response = await TestServerConnection.head('');

        if (response.status === 200)
            this.setState({
                server_connected: true
            })
    }


    // handle user entered user name
    onUserNameChanged(e) {
        this.setState(
            { user_name: e.target.value }
        )
    }

    // handle check in button clicked
    onCheckIn() {
        if (this.state.user_name === '') return;

        this.props.onUserCheckIn(this.state.user_name);
        this.setState(
            { checkedIn: true }
        )
    }

    // handle re-check in
    onReCheckIn() {
        this.setState(
            { user_name: "", checkedIn: false }
        )
        this.props.onUserCheckIn('')
    }


    // update data when props changed
    componentWillReceiveProps(nextProps) {
        if (nextProps.user_name !== this.state.user_name) {
            this.setState({
                user_name: nextProps.user_name
            })

            if (nextProps.user_name === '') {
                this.setState({
                    checkedIn: false
                })
            }
        }
    }


    // show check in form
    showCheckinForm() {
        return (
            <div className="ui middle aligned middle aligned center aligned grid" style={{ height: '100vh' }}>
                <div className="column">
                    <div className="ui centered container">
                        <h3>Login with your user name</h3>
                        <h3> </h3>
                    </div>
                    <div className="ui form">
                        <div className="inline field">
                            <label>User name:</label>
                            <input className="ui input" type="text" placeholder="user name"
                                disabled={(this.state.server_connected) ? "" : "disabled"}
                                value={this.state.user_name}
                                onChange={this.onUserNameChanged} />
                        </div>
                    </div>
                    <h3> </h3>
                    <button className="ui primary button"
                        disabled={(this.state.server_connected) ? "" : "disabled"}
                        onClick={this.onCheckIn}>Login</button>
                    <h3> </h3>
                    <div className="ui negative message"
                        style={{ display: this.state.server_connected ? 'none' : 'block' }}>
                        Connecting to API server...
                    </div>
                </div>
            </div>
        )
    }

    // content to show after user trys to login
    afterSuccessCheckin() {
        return (
            <div className="ui middle aligned middle aligned center aligned grid" style={{ height: '100vh' }}>
                <div className="column">
                    < h2 > Welcome: {this.state.user_name} </h2 >
                    <h2> </h2>
                    <h3>Now you can start your analysis work</h3>
                    <h2> </h2>
                    <div className="ui message"
                        style={{ display: this.state.user_name !== "" ? 'block' : 'none' }}>
                        <div style={{ fontWeight: 'bold' }}>
                            <span> Not {this.state.user_name}? </span>
                            <span>
                                <a href="#" onClick={this.onReCheckIn}> Login</a>
                            </span>
                        </div>
                    </div>
                </div>
            </div >
        )
    }


    render() {
        if (this.state.checkedIn && this.state.server_connected)
            return this.afterSuccessCheckin();
        else
            return this.showCheckinForm();
    }
}

export default CheckIn