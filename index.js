/**
 * Time Hu
 * 2018-03-10
 * Video
 * **/
'use strict';

import { requireNativeComponent, View } from 'react-native';
import PropTypes from 'prop-types';
var PlayerGinseng = {
        name: 'VideoPlayer',
        propTypes: {
            Poster: PropTypes.string,
            VideoUrl:PropTypes.string,
            Definition:PropTypes.string,
            PlayInfoList:PropTypes.array,
            ...View.propTypes // 包含默认的View的属性
    },
    };

const VideoPlayer=requireNativeComponent('VideoPlayer', PlayerGinseng);
module.exports=VideoPlayer;