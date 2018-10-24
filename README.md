# ZNStepSlider

![image](https://github.com/NixZhang5/ZNStepSlider/blob/master/screenshots/slider-screenshots.gif)

#### Language
Swift

#### 遇到的问题
IBDesignable not works with the frameworks which links with CocoaPods' framework.
Seems like it might be related to CocoaPods/CocoaPods#7606. For the time being I would downgrade CocoaPods and possibly Xcode or use the workaround
```
# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
```

#### 使用
```
_slider.scales = [0.1, 0.5];
_slider.value = 0.15;
```
