package com.rn_vitamin.bean;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2018/3/5.
 */

public class VideoBean implements Parcelable {
        /**
         * PlayURL : http://obukb5fdy.bkt.clouddn.com/icevideo/video/nayuta.mp4
         * Definition : LD
         */

        private String PlayURL;
        private String Definition;

        public String getPlayURL() {
            return PlayURL;
        }

        public void setPlayURL(String PlayURL) {
            this.PlayURL = PlayURL;
        }

        public String getDefinition() {
            return Definition;
        }

        public void setDefinition(String Definition) {
            this.Definition = Definition;
        }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {

    }
}
