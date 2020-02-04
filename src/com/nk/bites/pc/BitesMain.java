package com.nk.bites.pc;

import java.io.File;

import com.jogamp.newt.event.KeyEvent;
import com.nk.bites.main.Game;
import com.ovl.controls.Controller.Type;
import com.ovl.controls.ControllerEventListener;
import com.ovl.controls.ControllerKeybind;
import com.ovl.controls.ControllerManager;
import com.ovl.controls.arm.KeyboardController;
import com.ovl.controls.arm.MouseController;
import com.ovl.engine.EngineConfig;
import com.ovl.engine.OverloadEngine;
import com.ovl.engine.arm.OverloadEngineArm;
import com.ovl.utils.Vector2;

public class BitesMain {
	public static final String VERSION_NAME = "1.0";
	public static final int BUILD_NAME = 1;
	
	public static void main(String[] args){
		final Game game = new Game();
		game.mPlatform = new Game.Platform() {
			float mouseFix;
			
			@Override
			public void init() {
				mouseFix = OverloadEngine.getInstance().aspectRatio * 0.5f;
				
				ControllerEventListener mouseClickListener = new ControllerEventListener(){
					@Override
					public void handleEvent(long eventArg, Vector2 pos, int... params) {
						pos.x *= mouseFix;
						
						if (params[0] == 1){
							game.postClick(pos);
						}
					}
				};
				
				MouseController mouse = (MouseController)ControllerManager.getInstance().getController(Type.TYPE_MOUSE);
				mouse.addKeybind(new ControllerKeybind(0, mouseClickListener));
				mouse.addKeybind(new ControllerKeybind(1, mouseClickListener));
				mouse.startController();
				
				KeyboardController keyboard = (KeyboardController)ControllerManager.getInstance().getController(Type.TYPE_KEYBOARD);
				keyboard.addKeybind(new ControllerKeybind(KeyEvent.VK_ESCAPE, new ControllerEventListener(){
					@Override
					public void handleEvent(long eventArg, Vector2 pos, int... params) {
						OverloadEngine.getInstance().requestClose();
					}
				}));
				
				ControllerEventListener buttonListener = new ControllerEventListener(){
					@Override
					public void handleEvent(long eventArg, Vector2 pos, int... params) {
						if (params[0] == 1){
							game.onButton(eventArg);
						}
					}
				};
				keyboard.setUnmaskedCallback(buttonListener);
				
				keyboard.startController();
			}
		
			public String getVersion() {
				return VERSION_NAME;
			}
			
			public int getBuild() {
				return BUILD_NAME;
			}
		};
		
		EngineConfig cfg = new EngineConfig();
		cfg.game = game;
		cfg.title = "Undead bites";
		cfg.configPath = (new File("./resources/res/config.cfg")).getAbsolutePath();
		OverloadEngineArm engine = new OverloadEngineArm(cfg);
		engine.run();
	}
}
