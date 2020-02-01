/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  Button,
  TouchableHighlight,
  Image
} from 'react-native';


class QuickReport extends Component{
  render() {
    return (
      <View style = {styles.bigContainer}>
        <View style={styles.container}>
          <Text style={styles.textStyle}> QuickReport </Text>
        </View>

        <TouchableHighlight style={ styles.imageContainer }>
              <Image style={ styles.image } source={require('./img/camera-cropped.png')} />
         </TouchableHighlight>
       </View>
    );
  }
};

const styles = StyleSheet.create({

  bigContainer:
  {
    flex: 1
  },

  container:
  {
    flex: 0,
    left: 0,
    top: 0
  },

  textStyle:{
    fontSize: 60, top: 50, right: 0, color: 'gray'
  },

  imageContainer: {
    flex: 1,
    alignItems: 'stretch',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image: {
    height:200,
    width: 200,
    borderRadius: 100,
    backgroundColor: "green",
  }
});

export default QuickReport;
