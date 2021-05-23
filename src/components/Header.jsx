import React, {Component} from 'react';
import { AppBar, Toolbar, Grid, Typography } from '@material-ui/core';

class Header extends Component {

    render() {
        return (
        <AppBar position="static">
        <Toolbar>
            <Grid container justify="space-between">  
                <Typography variant="h6" align="left">{this.props.title}</Typography>
                <Typography align="right">
                    User: {this.props.address}
                </Typography>
            </Grid>
        </Toolbar>
        </AppBar>
        );
    }
};

export default Header;