import React from "react";
import { instanceOf } from 'prop-types';
import Sidebar from "react-sidebar";
import { withCookies, Cookies } from 'react-cookie';


import MaterialTitlePanel from "./material_title_panel";
import SidebarContent from "./sidebar_content";
import CheckIn from '../CheckIn';
import PipelinePage from '../pipeline_page/PipelinePage';
import AnalysisPage from '../analysis_page/AnalysisPage';
import SubmitJob from '../analysis_page/SubmitJob';
import JobDetail from '../analysis_page/JobDetail';

const styles = {
    contentHeaderMenuLink: {
        textDecoration: "none",
        color: "white",
        padding: 8
    },
    content: {
        padding: "16px"
    }
};

const mql = window.matchMedia(`(min-width: 800px)`);

class App extends React.Component {
    static propTypes = {
        cookies: instanceOf(Cookies).isRequired
    };

    constructor(props) {
        super(props);
        const { cookies } = props;
        const current_user_name = cookies.get('user_name') || "";

        this.mediaQueryChanged = this.mediaQueryChanged.bind(this);
        this.toggleOpen = this.toggleOpen.bind(this);
        this.onSetOpen = this.onSetOpen.bind(this);
        this.onMenuClicked = this.onMenuClicked.bind(this);
        this.onUserCheckIn = this.onUserCheckIn.bind(this);

        this.state = {
            user_name: current_user_name,
            current_page: 'checkin_page',
            checkin_page: <CheckIn onUserCheckIn={this.onUserCheckIn}
                user_name={current_user_name} />,
            pipeline_page: <PipelinePage user_name={current_user_name} />,
            createAnalysis_page: <SubmitJob onMenuClicked={this.onMenuClicked}
                user_name={current_user_name} />,
            my_analysis_page: <AnalysisPage user_name={current_user_name}
                onMenuClicked={this.onMenuClicked} />,
            all_analysis_page: <AnalysisPage user_name=''
                onMenuClicked={this.onMenuClicked} />,
            jobDetail_page: <JobDetail />,
            docked: mql.matches,
            open: false
        };
    }

    componentWillMount() {
        mql.addListener(this.mediaQueryChanged);
    }

    componentWillUnmount() {
        mql.removeListener(this.mediaQueryChanged);
    }

    onSetOpen(open) {
        this.setState({ open });
    }

    mediaQueryChanged() {
        this.setState({
            docked: mql.matches,
            open: false
        });
    }

    toggleOpen(ev) {
        this.setState({ open: !this.state.open });

        if (ev) {
            ev.preventDefault();
        }
    }

    // function to update current page, passed to the sidebar component
    // the only special case is if we want to go to the 
    // job detail page we need the run id passed in
    onMenuClicked(page_name, the_data) {
        if (page_name === 'jobDetail_page')
            this.setState({
                jobDetail_page: <JobDetail data={the_data} />,
            })

        this.setState({
            current_page: page_name
        });
    };

    // function to update current user name, passed to the check in page through side-bar
    onUserCheckIn(the_user_name) {
        const { cookies } = this.props;
        cookies.set('user_name', the_user_name);

        this.setState({
            user_name: the_user_name,
            checkin_page: <CheckIn onUserCheckIn={this.onUserCheckIn}
                user_name={the_user_name} />,
            pipeline_page: <PipelinePage user_name={the_user_name} />,
            createAnalysis_page: <SubmitJob onMenuClicked={this.onMenuClicked}
                user_name={the_user_name} />,
            my_analysis_page: <AnalysisPage user_name={the_user_name}
                onMenuClicked={this.onMenuClicked} />,
            all_analysis_page: <AnalysisPage user_name=''
                onMenuClicked={this.onMenuClicked} />,
        })
    }

    render() {
        const sidebar = <SidebarContent
            onMenuClicked={this.onMenuClicked}
            onUserCheckIn={this.onUserCheckIn} />;

        const contentHeader = (
            <span>
                {!this.state.docked && (
                    <a
                        onClick={this.toggleOpen}
                        href
                        style={styles.contentHeaderMenuLink}>=</a>
                )}
                <span> A Novel OMERO-Based Biomedical Imaging Platform</span>
            </span>
        );

        const sidebarProps = {
            sidebar,
            docked: this.state.docked,
            open: this.state.open,
            onSetOpen: this.onSetOpen
        };

        // const loginPage = <Login />
        // const pipelinePage = <PipelinePage />
        return (
            <Sidebar {...sidebarProps}>
                <MaterialTitlePanel title={contentHeader}>
                    {this.state.user_name === '' ?
                        this.state.checkin_page : this.state[this.state.current_page]}
                </MaterialTitlePanel>
            </Sidebar>
        );
    }
}

export default withCookies(App);
