//
//  AppView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import ARKit

struct AppView: View {
    @EnvironmentObject var state: AppState
    @State private var newSession: Bool = false
    @State private var details: UUID?
    @State private var loadingDetails: Bool = false
    var dList: some View {
        ZStack {
            ScrollView {
                VStack {
                    ForEach(state.ductData) { d in
                        NavView(data: d, isShown: state.navSelection == nil, details: $details, nav: $state.navSelection, loading: $loadingDetails)
                    }
                    Button(action: {
                        newSession = true
                    }, label: {
                        Text("New Session").font(.title)
                    })
                }
                .padding()
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: navItems)
            .sheet(isPresented: $newSession) {
                NewSessionSheet(isPresented: $newSession).environmentObject(state)
            }
            Group {
                helpWebSheet
                aboutSheet
                shareSheet
                detailsSheet
                EmptyView()
                    .sheet(isPresented: Binding<Bool>(get: {state.pdfDuct != nil}, set: {if !$0 { state.pdfDuct = nil }}), content: {PDFView(duct: state.pdfDuct ?? Duct()).environmentObject(state)})
            }
        }
    }
    
    var helpWebSheet: some View {
        EmptyView()
        .sheet(isPresented: $state.sheetsShown.helpWeb, content: {
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            state.sheetsShown.helpWeb = false
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .padding()
                                .background(BlurEffectView())
                                .clipShape(Circle())
                        })
                        Spacer()
                    }
                    Spacer()
                }.zIndex(2)
                HelpWebKitView().environmentObject(state).zIndex(1)
            }
            
        })
    }
    var aboutSheet: some View {
        EmptyView()
        .sheet(isPresented: $state.sheetsShown.about, content: {AboutView().environmentObject(state)})
    }
    var shareSheet: some View {
        EmptyView()
            .sheet(isPresented: Binding<Bool>(get: {
                state.shareURL != nil
            }, set: {
                if !$0 { state.shareURL = nil }
            }), content: {
                ActivityView(activityItems: [state.shareURL ?? ""], applicationActivities: nil)
        })
    }
    var detailsSheet: some View {
        EmptyView()
            .sheet(isPresented: Binding<Bool>(get: {details != nil}, set: {
                if $0 {
                    loadingDetails = true
                } else {
                    details = nil
                }
            })) {detailsView.environmentObject(state)}
    }
    var detailsView: AnyView {
        if details != nil {
            if let duct = state.ductData.first(where: {$0.id == details}) {
                let df = DateFormatter()
                df.dateStyle = .long
                return AnyView(VStack {
                    Text("Details").font(.title)
                    Divider()
                    Group {
                        Text("Name: \(duct.name)")
                        Text("Created: \(df.string(from: duct.created))")
                        Text("Units: \(duct.width.value.unit.symbol)")
                        HStack {
                            Text("Width:")
                            duct.width.value.asElement
                        }
                        HStack {
                            Text("Depth:")
                            duct.depth.value.asElement
                        }
                        HStack {
                            Text("Length:")
                            duct.length.value.asElement
                        }
                        HStack {
                            Text("Offset X:")
                            duct.offsetx.value.asElement
                        }
                        Group {
                            HStack {
                                Text("Offset Y:")
                                duct.offsety.value.asElement
                            }
                            HStack {
                                Text("T Width:")
                                duct.twidth.value.asElement
                            }
                            HStack {
                                Text("T Depth:")
                                duct.tdepth.value.asElement
                            }
                            ZStack {
                                DuctSceneUIPreview(duct: Duct(data: duct), loading: $loadingDetails).opacity(loadingDetails ? 0 : 1)
                                LoadSceneProgressView().opacity(loadingDetails ? 1 : 0)
                            }.scaledToFit().animation(.easeInOut)
                        }
                    }
                })
            }
            else { return AnyView(EmptyView()) }
        }
        else { return AnyView(EmptyView())}
    }
    
    var navItems: some View {
        HStack {
            NavigationLink(
                destination: SettingsPage(),
                tag: "Settings",
                selection: $state.currentPage,
                label: {Image(systemName: "gear")})
            NavigationLink(
                destination: WorkSettingsView(data: Binding<Duct>(get: {state.currentWork ?? Duct()}, set: {state.currentWork = $0})),
                tag: "Work Settings",
                selection: $state.currentPage,
                label: {EmptyView()})
        }
    }
    
    var body: some View {
        NavigationView { dList }
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NewSessionSheet: View {
    @State var sessionName: String = ""
    @Binding var isPresented: Bool
    @EnvironmentObject var state: AppState
    var body: some View {
        Form {
            Section(header: Text("Session name")) {
                TextField("New name", text: $sessionName)
                Button(action: {
                    state.ductData.append(DuctData(
                                            name: sessionName,
                                            units: state.defaultUnits))
                    state.navSelection = state.ductData.last?.id
                    isPresented = false
                }, label: {
                    Text("Create")
                })
            }
        }
    }
}

struct PDFView: View {
    var duct: Duct
    let ductFont: Font? = .title3
    let ductBorderColor: Color = .black
    let ductBorderWidth: CGFloat = 1
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                HStack {
                    Image("FieldFab Logo")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Spacer()
                }.frame(maxWidth: .infinity)
                HStack(alignment: .top, spacing: 0) {
                    Text("FieldFab")
                    Text("©").font(.body)
                    Text(" Duct Fabrication")
                }
                .font(.largeTitle)
                .fixedSize(horizontal: true, vertical: false)
                HStack {
                    
                }.frame(maxWidth: .infinity)
            }
            Text(duct.data.name).font(.title2)
            Text("Units: \(duct.data.width.value.unit.symbol)").font(.title3)
            HStack {
                ZStack {
                    DuctSideView(face: .front, forceHelpersOff: true, duct: .constant(duct)).scaledToFit()
                    Text("Front").font(ductFont)
                }
                .border(ductBorderColor, width: ductBorderWidth)
                ZStack {
                    DuctSideView(face: .back, forceHelpersOff: true, duct: .constant(duct)).scaledToFit()
                    Text("Back").font(ductFont)
                }
                .border(ductBorderColor, width: ductBorderWidth)
            }
            HStack {
                ZStack {
                    DuctSideView(face: .left, forceHelpersOff: true, duct: .constant(duct)).scaledToFit()
                    Text("Left").font(ductFont)
                }
                .border(ductBorderColor, width: ductBorderWidth)
                ZStack {
                    DuctSideView(face: .right, forceHelpersOff: true, duct: .constant(duct)).scaledToFit()
                    Text("Right").font(ductFont)
                }
                .border(ductBorderColor, width: ductBorderWidth)
            }
        }.padding().environment(\.colorScheme, .light)
    }
}

struct NavView: View {
    var data: DuctData
    var isShown: Bool
    @Binding var details: UUID?
    @Binding var nav: UUID?
    @Binding var loading: Bool
    @EnvironmentObject var state: AppState
    func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .long
        return df.string(from: date)
    }
    
    var navLink: some View {
        NavigationLink(
            destination: WorkView().popup(isPresented: $state.popupSaveSuccessful, type: .toast, animation: .easeInOut, autohideIn: 2, view: {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Spacer()
                        Text("Session saved successfully")
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 30, alignment: .center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer().frame(height: 20)
                }.opacity(state.popupSaveSuccessful ? 1 : 0)
            }),
            tag: data.id,
            selection: $nav,
            label: {
                Text("\(data.name)").font(.title2)
            }).lineLimit(1)
    }
    var shareButton: some View {
        Button(action: {
            state.shareURL = data.toURL()
        }, label: {
            Image(systemName: "square.and.arrow.up").padding(.horizontal, 4)
        })
    }
    var exportButton: some View {
        Button(action: {
            state.pdfDuct = Duct(data: data)
        }, label: {Text("Export")})
    }
    
    struct Mod: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.gray.opacity(0.025))
                .background(BlurEffectView())
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
//                shareButton.
                navLink
//                exportButton.opacity(0)
            }
            Divider()
            Text("Created on \(formatDate(data.created))")
            Divider()
            HStack {
                Button(action: {
                    details = data.id
                    loading = true
                }, label: {
                    Text("Details").padding(.trailing, 4)
                })
                Spacer()
                Button(action: {
                    state.ductData = state.ductData.filter({v in v.id != data.id})
                }, label: {
                    Image(systemName: "trash")
                }).foregroundColor(.red)
            }
        }
        .modifier(Mod())
    }
}



struct DuctScenePreview: UIViewRepresentable {
    typealias UIViewType = DuctSceneView
    var duct: Duct
    @EnvironmentObject var state: AppState
    @Binding var loading: Bool
    
    func makeUIView(context: Context) -> UIViewType {
        let view = UIViewType(frame: CGRect.zero)
        view.rendersContinuously = false
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling2X
        view.scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets") ?? SCNScene()
//        view.delegate = nd
//        view.wg = DispatchWorkItem(block: {loading = false})
        view.fullUpdate(update: .init(scene: .init(duct: duct, color: state.sceneBGColor, image: state.sceneBGTexture), material: .init(material: state.material, lighting: state.lightingModel), helpers: .init(enabled: state.showHelpers, intensity: 0.25)), onComplete: {})
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}

class SceneAsync {
    let queue = DispatchQueue.global(qos: .userInteractive)
    let group = DispatchGroup()
    let sem = DispatchSemaphore(value: 1)
}

//class DuctSceneDelegate: NSObject, SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        let r = (renderer as! DuctSceneView)
//        r.disp.group.notify(queue: r.disp.queue, work: r.wg ?? .init(block: {}))
//    }
//}

struct DuctSceneUIPreview: View {
    var duct: Duct
    @EnvironmentObject var state: AppState
    @Binding var loading: Bool
    var scene: SCNScene {
        let scn = SCNScene()
        let async = SceneAsync()
        scn.generateScene(duct: duct, bgColor: state.sceneBGColor, bgImage: state.sceneBGTexture, async: async)
        scn.setMaterial(material: state.material, lighting: state.lightingModel, async: async)
        scn.setHelpers(false, intensity: 0.25, async: async)
        async.group.wait()
        loading = false
        return scn
    }
    
    var body: some View {
        SceneView(scene: scene, options: SceneView.Options([.allowsCameraControl, .autoenablesDefaultLighting]))
    }
}

class DuctSceneView: SCNView {
    let disp = SceneAsync()
    struct Update {
        let scene: Scene
        let material: Material
        let helpers: Helpers
        init(scene: Scene?, material: Material?, helpers: Helpers?) {
            self.scene = scene ?? Scene(); self.material = material ?? Material(); self.helpers = helpers ?? Helpers()
        }
        struct Scene {
            let duct: Duct
            let bgColor: CGColor
            let bgImage: String?
            init(duct: Duct = Duct(), color: CGColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1), image: String? = nil) {
                self.duct = duct; bgColor = color; bgImage = image
            }
        }
        struct Material {
            let material: String
            let lighting: LightingModel
            init(material: String = "galvanized", lighting: LightingModel = .physicallyBased) {
                self.material = material; self.lighting = lighting
            }
        }
        struct Helpers {
            let enabled: Bool
            let intensity: CGFloat
            init(enabled: Bool = false, intensity: CGFloat = 0.25) {
                self.enabled = enabled; self.intensity = intensity
            }
        }
    }
    func fullUpdate(update: Update, onComplete: @escaping () -> Void) {
        scene?.generateScene(duct: update.scene.duct, bgColor: update.scene.bgColor, bgImage: update.scene.bgImage, async: disp)
        scene?.setMaterial(material: update.material.material, lighting: update.material.lighting, async: disp)
        scene?.setHelpers(update.helpers.enabled, intensity: update.helpers.intensity, async: disp)
    }
    func updateMaterials(update: Update.Material, onComplete: @escaping () -> Void) {
        scene?.setMaterial(material: update.material, lighting: update.lighting, async: disp)
    }
    func updateHelpers(update: Update.Helpers, onComplete: @escaping () -> Void) {
        scene?.setHelpers(update.enabled, intensity: update.intensity, async: disp)
    }
}

extension SCNScene {
    func setMaterial(material: String = "galvanized", lighting: LightingModel = .physicallyBased, async: SceneAsync = SceneAsync()) {
        async.group.enter()
        async.queue.async {
            async.sem.wait()
            defer {
                async.group.leave()
                async.sem.signal()
            }
            let names: [String] = [
                "tab-front-left", "tab-front-right", "tab-front-top", "tab-front-bottom", "tab-left-left", "tab-left-right", "tab-left-top", "tab-left-bottom", "tab-right-left", "tab-right-right", "tab-right-top", "tab-right-bottom", "tab-back-left", "tab-back-right", "tab-back-top", "tab-back-bottom", "Front", "Back", "Left", "Right"
            ]
            for i in names {
                let n = self.rootNode.childNode(withName: i, recursively: true)
                n?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(material)-diffuse")
                n?.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(material)-normal")
                n?.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(material)-metallic")
                n?.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(material)-roughness")
                n?.geometry?.firstMaterial?.lightingModel = lighting.scn
            }
        }
    }
    func setHelpers(_ enabled: Bool = false, intensity i: CGFloat = 0.25, async: SceneAsync = SceneAsync()) {
        async.group.enter()
        async.queue.async {
            async.sem.wait()
            defer {
                async.group.leave()
                async.sem.signal()
            }
            if enabled {
                self.rootNode.childNode(withName: "Front", recursively: true)?.geometry?.firstMaterial?.emission.contents = UIColor(red: 0, green: i, blue: 0, alpha: i)
                self.rootNode.childNode(withName: "Back", recursively: true)?.geometry?.firstMaterial?.emission.contents =  UIColor(red: i, green: 0, blue: 0, alpha: i)
                self.rootNode.childNode(withName: "Left", recursively: true)?.geometry?.firstMaterial?.emission.contents =  UIColor(red: i, green: i, blue: 0, alpha: i)
                self.rootNode.childNode(withName: "Right", recursively: true)?.geometry?.firstMaterial?.emission.contents = UIColor(red: 0, green: 0, blue: i, alpha: i)
            } else {
                self.rootNode.childNode(withName: "Front", recursively: true)?.geometry?.firstMaterial?.emission.contents = nil
                self.rootNode.childNode(withName: "Back", recursively: true)?.geometry?.firstMaterial?.emission.contents =  nil
                self.rootNode.childNode(withName: "Left", recursively: true)?.geometry?.firstMaterial?.emission.contents =  nil
                self.rootNode.childNode(withName: "Right", recursively: true)?.geometry?.firstMaterial?.emission.contents = nil
            }
        }
    }
    func generateScene(duct: Duct, bgColor: CGColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1), bgImage: String? = nil, async: SceneAsync = SceneAsync()) {
        async.group.enter()
        async.queue.async {
            async.sem.wait()
            defer {
                async.group.leave()
                async.sem.signal()
            }
            let ductNode = SCNNode()
            ductNode.name = "DuctNode"
            for (_, v) in duct.getNodes() {
                ductNode.addChildNode(v)
            }
            let camera = SCNCamera()
            camera.fieldOfView = 90
            camera.zFar = 100
            camera.zNear = 0.0001
            let camNode = SCNNode()
            camNode.worldPosition = SCNVector3(0, 0, max(duct.data.width.rendered3D, duct.data.depth.rendered3D) * 2)
            camNode.camera = camera
            if let img = bgImage {
                self.background.contents = UIImage(named: img)
                self.lightingEnvironment.contents = UIImage(named: img)
            } else {
                self.background.contents = bgColor
                self.lightingEnvironment.contents = bgColor
            }
            self.rootNode.addChildNode(camNode)
            self.rootNode.addChildNode(ductNode)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {

    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let width = Measurement<UnitLength>(value: 18, unit: .inches)
        let depth = Measurement<UnitLength>(value: 20, unit: .inches)
        let length = Measurement<UnitLength>(value: 6, unit: .inches)
        let offsetx = Measurement<UnitLength>(value: 0, unit: .inches)
        let offsety = Measurement<UnitLength>(value: 0, unit: .inches)
        let twidth = Measurement<UnitLength>(value: 20, unit: .inches)
        let tdepth = Measurement<UnitLength>(value: 18, unit: .inches)
        var tabs = DuctTabContainer()
        tabs.ft = .init(length: .inch, type: .straight)
        tabs.fb = .init(length: .inch, type: .straight)
        tabs.bt = .init(length: .inch, type: .straight)
        tabs.bb = .init(length: .inch, type: .straight)
        tabs.lt = .init(length: .inch, type: .straight)
        tabs.lb = .init(length: .inch, type: .straight)
        tabs.ll = .init(length: .inch, type: .straight)
        tabs.lr = .init(length: .inch, type: .straight)
        tabs.rt = .init(length: .inch, type: .straight)
        tabs.rb = .init(length: .inch, type: .straight)
        tabs.rl = .init(length: .inch, type: .straight)
        tabs.rr = .init(length: .inch, type: .straight)
        return PDFView(duct: Duct(data: .init(name: "Some duct", id: UUID(), created: Date(), width: .init(value: width), depth: .init(value: depth), length: .init(value: length), offsetx: .init(value: offsetx), offsety: .init(value: offsety), twidth: .init(value: twidth), tdepth: .init(value: tdepth), type: DuctData.DType.fourpiece, tabs: tabs))).environmentObject(AppState())
    }
}
#endif
