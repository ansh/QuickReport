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
      <View style={styles.container}>
       <Text style={{ fontSize:22 }}>Only image clickable</Text>
       <TouchableHighlight style={ styles.imageContainer }>
            <Image style={ styles.image } source={require('./img/camera-cropped.png')} />
       </TouchableHighlight>
       <Text style={{ fontSize:22 }}>Entire Row Clickable</Text>
       <TouchableHighlight style={ styles.imageContainer2 }>
            <Image style={ styles.image } source={{ uri: 'http://www.free-avatars.com/data/media/37/cat_avatar_0597.jpg' }} />
       </TouchableHighlight>
      </View>
    );
  }
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop:60
  },
  imageContainer: {
    height:128,
    width: 128,
    borderRadius: 64
  },
  image: {
    height:128,
    width: 128,
    borderRadius: 64,
    backgroundColor: "green",
  },
  imageContainer2: {
  }
});

export default QuickReport;
