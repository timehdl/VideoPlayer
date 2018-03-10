package com.rn_vitamin;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.facebook.react.ReactActivity;
import com.rn_vitamin.Utils.PixelUtils;
import com.rn_vitamin.vitamin_plugin.MyMediaController;
import com.rn_vitamin.vitamin_plugin.ReactVideoManager;

import io.vov.vitamio.MediaPlayer;
import io.vov.vitamio.widget.MediaController;
import io.vov.vitamio.widget.VideoView;

public class MainActivity extends ReactActivity {

    //当前是否为全屏
    private Boolean mIsFullScreen = false;
    private RelativeLayout mFlVideoGroup;
    private RelativeLayout mrela_layout;
    private VideoView mVideoView;
    //存储播放进度
    public SharedPreferences sharedPreferences;
    private SharedPreferences.Editor editor;
    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "Rn_Vitamin";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        setContentView(R.layout.video_layout);
//        mFlVideoGroup= (FrameLayout) findViewById(R.id.fl_video_group);
//        mVideoView= (VideoView) findViewById(R.id.surface_view);
        //获取sharedPreferences对象
        sharedPreferences = getSharedPreferences("playPosition", Context.MODE_PRIVATE);
        //获取editor对象
        editor = sharedPreferences.edit();//获取编辑器
    }

    @Override
    protected void onPause() {
        super.onPause();
        VideoView videoView=getmVideoView();
        if(videoView.isPlaying()){
            videoView.pause();//停止播放
            long currentPosition=videoView.getCurrentPosition();
            //存储键值对
            editor.putLong("currentPosition", currentPosition);
            //提交
            editor.commit();//提交修改
        }
    }

    //记得在activity中声明
    // android:screenOrientation="portrait" 强行设置为竖屏，关闭自动旋转屏幕
    //android:configChanges="orientation|keyboardHidden|screenLayout|screenSize"注册配置变化事件
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mFlVideoGroup= getRelativeLayout();
        mVideoView=getmVideoView();
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            //横屏
            mIsFullScreen = true;
            //去掉系统通知栏
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN);
            //调整mFlVideoGroup布局参数
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT);
            mrela_layout.setLayoutParams(params);
            RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT);
            mFlVideoGroup.setLayoutParams(layoutParams1);
            //原视频大小
//            public static final int VIDEO_LAYOUT_ORIGIN = 0;
            //最优选择，由于比例问题还是会离屏幕边缘有一点间距，所以最好把父View的背景设置为黑色会好一点
//            public static final int VIDEO_LAYOUT_SCALE = 1;
            //拉伸，可能导致变形
//            public static final int VIDEO_LAYOUT_STRETCH = 2;
            //会放大可能超出屏幕
//            public static final int VIDEO_LAYOUT_ZOOM = 3;
            //效果还是竖屏大小（字面意思是填充父View）
//            public static final int VIDEO_LAYOUT_FIT_PARENT = 4;
            mVideoView.setVideoLayout(VideoView.VIDEO_LAYOUT_SCALE, 0);
        } else {
            mIsFullScreen = false;
            /*清除flag,恢复显示系统状态栏*/
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout
                    .LayoutParams.MATCH_PARENT,
                    PixelUtils.dip2px(this,250));
            mrela_layout.setLayoutParams(params);

            RelativeLayout.LayoutParams params1 = new RelativeLayout.LayoutParams(RelativeLayout
                    .LayoutParams.MATCH_PARENT,
                    PixelUtils.dip2px(this,250));
            mFlVideoGroup.setLayoutParams(params1);

//            RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(
//                    RelativeLayout.LayoutParams.MATCH_PARENT,
//                    RelativeLayout.LayoutParams.MATCH_PARENT);
//            mVideoView.setLayoutParams(layoutParams1);
        }
    }


    public void setRelativeLayout(RelativeLayout relativeLayout){
        mFlVideoGroup=relativeLayout;
    }

    private RelativeLayout getRelativeLayout(){
        return mFlVideoGroup;
    }

    public VideoView getmVideoView() {
        return mVideoView;
    }

    public void setmVideoView(VideoView mVideoView) {
        this.mVideoView = mVideoView;
    }

    public RelativeLayout getMrela_layout() {
        return mrela_layout;
    }

    public void setMrela_layout(RelativeLayout mrela_layout) {
        this.mrela_layout = mrela_layout;
    }
}
