import React from "react";
import PropTypes from "prop-types";
import MaterialTitlePanel from "./material_title_panel";
import '../../css/style.css';

const styles = {
    sidebar: {
        width: 256,
        height: "100%"
    },
    sidebarLink: {
        display: "block",
        padding: "16px 0px",
        fontWeight: 'bold',
        color: "#757575",
        textDecoration: "none"
    },
    divider: {
        margin: "8px 0",
        height: 1,
        backgroundColor: "#757575"
    },
    content: {
        padding: "16px",
        height: "100%",
        backgroundColor: "white"
    }
};


class SidebarContent extends React.Component {
    constructor(props) {
        super(props);
        const the_links = [];

        this.state = {
            style: props.style
                ? { ...styles.sidebar, ...props.style }
                : styles.sidebar,
            links: the_links
        }
    }

    render() {
        return (
            <MaterialTitlePanel title="OBI-1" style={this.state.style}>
                <div style={styles.content}>
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onMenuClicked('checkin_page')}>
                            Log in
                        </button>
                    </div>
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onMenuClicked('pipeline_page')}>
                            Manage Pipelines
                        </button>
                    </div>
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onMenuClicked('createAnalysis_page')}>
                            Create New Analysis
                        </button>
                    </div>
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onMenuClicked('my_analysis_page')}>
                            My Runs
                        </button>
                    </div>
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onMenuClicked('all_analysis_page')}>
                            All Runs
                        </button>
                    </div>

                    <div style={styles.divider} />
                    <div>
                        <button className="link-button" style={styles.sidebarLink}
                            onClick={() => this.props.onUserCheckIn('')}>
                            Log Out
                        </button>
                    </div>
                    {this.state.links}
                </div>
            </MaterialTitlePanel>
        );
    }

};

SidebarContent.propTypes = {
    style: PropTypes.object
};

export default SidebarContent;
