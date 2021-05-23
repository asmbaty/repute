import React, {Component} from 'react';
import { AppBar, Toolbar, Grid, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

class Header extends Component {
    constructor(props) {
        super(props)
    }    

    render() {
        return (
        <AppBar position="static">
        <Toolbar>
            <Grid container justify="space-between">  
                <Typography inline variant="h6" align="left">{this.props.title}</Typography>
                <Typography inline align="right">
                    User: {this.props.address}
                </Typography>
            </Grid>
        </Toolbar>
        </AppBar>
        );
    }
};

export default Header;