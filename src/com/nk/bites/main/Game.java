package com.nk.bites.main;

import java.util.ArrayList;

import com.ovl.game.BaseGame;
import com.ovl.graphics.Layer;
import com.ovl.script.LuaCallable;
import com.ovl.script.LuaScript;
import com.ovl.utils.Paths;
import com.ovl.utils.Vector2;

public class Game extends BaseGame {
	public static interface Platform {
		public void init();
		public String getVersion();
		public int getBuild();
	}
	
	public Platform mPlatform;
	private ArrayList<Vector2> mClickList = new ArrayList<>();
	
	private LuaScript mScript;
	private LuaCallable mUpdateFun;
	private LuaCallable mOnClickFun;
	private LuaCallable mOnButtonFun;
	
	public int getBuild() {
		return mPlatform.getBuild();
	}
	
	public String getVersion() {
		return mPlatform.getVersion();
	}
	
	@Override
	public void init() {
		super.init();
		mPlatform.init();
		
		restart();
	}
	
	public void onButton(long mask) {
		mOnButtonFun.callSafe(mask);
	}
	
	public void postClick(Vector2 pos){
		synchronized (mClickList){
			mClickList.add(pos);
		}
	}
	
	@Override
	public void update(float deltaTime) {
		super.update(deltaTime);
		
		synchronized (mClickList){
			for (Vector2 pos : mClickList){
				mOnClickFun.callSafe(pos);
			}
			mClickList.clear();
		}

		mUpdateFun.callSafe(deltaTime);
	}

	public void restart() {
		for (Layer l : layers) {
			l.destroy();
		}
		
		mScript = new LuaScript(Paths.SCRIPTS + "main.lua");
		assert(mScript.hasContents());
		mUpdateFun = mScript.getCallable("update");
		mOnClickFun = mScript.getCallable("onClick");
		mOnButtonFun = mScript.getCallable("onButton");
		mScript.call("init");
	}
}
