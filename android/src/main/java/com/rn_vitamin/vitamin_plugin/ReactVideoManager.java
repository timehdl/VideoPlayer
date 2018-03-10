package com.rn_vitamin.vitamin_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.danikula.videocache.HttpProxyCacheServer;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.rn_vitamin.MainActivity;
import com.rn_vitamin.MainApplication;
import com.rn_vitamin.R;
import com.rn_vitamin.bean.VideoBean;
import com.rn_vitamin.model.SwitchVideoModel;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.HashMap;

import io.vov.vitamio.MediaPlayer;
import io.vov.vitamio.widget.VideoView;


/**
 * Created by Administrator on 2018/2/7.
 */

public class ReactVideoManager  extends ViewGroupManager<RelativeLayout> {

    public static final String REACT_CLASS = "RCTVideoView";
    private static Context mContext;
    public VideoView mVideoView;
    private MyMediaController mMediaController;
    private Activity activity;
    private MainActivity act;
    private RelativeLayout videoLayout;
    private ImageView imageView,image_start;
    //锁屏
    private ImageView lockScreen;
    private TextView audio_video;
    //切换标记
    private boolean flag=true;
    //切换音视频
    private boolean flag1=true;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected RelativeLayout createViewInstance(ThemedReactContext reactContext) {
        mContext=reactContext;
        activity=reactContext.getCurrentActivity();
        act= (MainActivity) activity;
        //mVideoView=new VideoView(reactContext);
        LayoutInflater inflater=LayoutInflater.from(mContext);
        videoLayout= (RelativeLayout) inflater.inflate(R.layout.video_layout,null);
        RelativeLayout relativeLayout= (RelativeLayout) videoLayout.findViewById(R.id.rela_layout);
        mVideoView= (io.vov.vitamio.widget.VideoView) videoLayout.findViewById(R.id.surface_view);
        imageView= (ImageView) videoLayout.findViewById(R.id.image_view);
        lockScreen= (ImageView) videoLayout.findViewById(R.id.lock_screen);
        lockScreen.setOnClickListener(lockScreenListener);
        audio_video= (TextView) videoLayout.findViewById(R.id.audio_video);
        audio_video.setOnClickListener(audioVideoListener);
        mMediaController=new MyMediaController(mContext,mVideoView,act);
        act.setMrela_layout(videoLayout);
        act.setRelativeLayout(relativeLayout);
        act.setmVideoView(mVideoView);
        return videoLayout;
    }
    //锁屏监听
    private View.OnClickListener lockScreenListener = new View.OnClickListener() {
        public void onClick(View v) {
            lockScreen();
        }
    };
    //音视频切换
    private View.OnClickListener audioVideoListener = new View.OnClickListener() {
        public void onClick(View v) {
            changeAudioVideo();
        }
    };

    @Override
    public void onDropViewInstance(RelativeLayout view) {//对象销毁时

        super.onDropViewInstance(view);
    }

    @ReactProp(name = "videoUrl")
    public void setVideoUrl(RelativeLayout view, final String videoUrl) {
//        final RelativeLayout relativeLayout= (RelativeLayout) view.findViewById(R.id.re_layout);
//        final VideoView videoView= (VideoView) view.findViewById(R.id.surface_view);
//        mMediaController.setVisibility(View.GONE);
        image_start= (ImageView) view.findViewById(R.id.start_btn);
        final ProgressBar progressBar= (ProgressBar) view.findViewById(R.id.progressBar);
        image_start.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                image_start.setVisibility(View.GONE);
                progressBar.setVisibility(View.VISIBLE);
//                mVideoView.setVideoPath(videoUrl);
                //缓存本地视频
                HttpProxyCacheServer proxy = getProxy();
                String proxyUrl = proxy.getProxyUrl(videoUrl);
                mVideoView.setVideoPath(proxyUrl);
                mVideoView.setMediaController(mMediaController);
                mVideoView.requestFocus();
                final long currentPosition=act.sharedPreferences.getLong("currentPosition",0);
                mVideoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mediaPlayer) {
                        // optional need Vitamio 4.0
                        mediaPlayer.setPlaybackSpeed(1.0f);
                        mVideoView.seekTo(currentPosition);
                        progressBar.setVisibility(View.GONE);
                        imageView.setVisibility(View.GONE);
                        lockScreen.setVisibility(View.VISIBLE);
                        audio_video.setVisibility(View.VISIBLE);
                        mVideoView.setVideoLayout(VideoView.VIDEO_LAYOUT_SCALE, 0);
                    }
                });
            }
        });

    }

    @ReactProp(name = "poster")
    public void setPoster(RelativeLayout view, String poster) {
        imageView= (ImageView) view.findViewById(R.id.image_view);
        Picasso.with(mContext)
                .load(poster)
                .into(imageView);
    }

    @ReactProp(name = "playInfoList")
    public void setPlayInfoList(RelativeLayout view, ReadableMap playInfoList) {
        HashMap<String,Object> map;
        ReadableNativeMap map2 = (ReadableNativeMap) playInfoList;
        map = map2.toHashMap();
        ArrayList<HashMap<String,String>> arrayList= (ArrayList<HashMap<String,String>>) map.get("PlayInfo");
        for (int i = 0; i <arrayList.size() ; i++) {
            HashMap<String,String> map1=arrayList.get(i);
            String defination=map1.get("Definition");
            String playUrl=map1.get("PlayURL");
            SwitchVideoModel switchVideoModel=new SwitchVideoModel(defination,playUrl);
//            detailPlayer.mUrlList.add(switchVideoModel);
//            VideoBean videoBean=new VideoBean();
//            videoBean.setDefinition(defination);
//            videoBean.setPlayURL(playUrl);
            mMediaController.mUrlList.add(switchVideoModel);
        }
    }

    /**
     * 锁屏
     */
    private void lockScreen(){
        if(flag){
            lockScreen.setImageResource(R.drawable.lock);
            mMediaController.setVisibility(View.GONE);
            audio_video.setVisibility(View.GONE);
        }else {
            lockScreen.setImageResource(R.drawable.unlock);
            mMediaController.setVisibility(View.VISIBLE);
            audio_video.setVisibility(View.VISIBLE);
        }
        flag=!flag;
    }

    /**
     * 切换音视频
     */
    private void changeAudioVideo(){
        if(flag1){
            imageView.setVisibility(View.VISIBLE);
            lockScreen.setVisibility(View.GONE);
        }else {
           imageView.setVisibility(View.GONE);
           lockScreen.setVisibility(View.VISIBLE);
        }
        flag1=!flag1;
    }

    private HttpProxyCacheServer getProxy() {
        // should return single instance of HttpProxyCacheServer shared for whole app.
        return MainApplication.getProxy(mContext);
    }
}
