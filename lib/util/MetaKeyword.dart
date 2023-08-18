class MetaKeyword {
  static const String Prompt = "prompt";
  static const String Negative_prompt = "negative_prompt";
  static const String Steps = "steps";
  static const String Sampler = "sampler";
  static const String CFG_scale = "cfg_scale";
  static const String Seed = "seed";
  static const String Size = "size";
  static const String Model_hash = "model_hash";
  static const String Model = "model";
  static const String Clipskip = "clipskip";
  static const String ControlNet = "controlnet";
}

class MetaKeywordTable {
  static final Map<String, String> A1111 = {
    MetaKeyword.Prompt: "Parameters:",
    MetaKeyword.Negative_prompt: "Negative prompt:",
    MetaKeyword.Steps: "Steps:",
    MetaKeyword.Sampler: "Sampler:",
    MetaKeyword.CFG_scale: "CFG scale:",
    MetaKeyword.Seed: "Seed:",
    MetaKeyword.Model_hash: "Model hash:",
    MetaKeyword.Model: "Model:",
    MetaKeyword.Clipskip: "Clip skip:",
    MetaKeyword.ControlNet: "Control net:",
  };

  static final Map<String, String> InvokeAI = {
    MetaKeyword.Prompt: "positive_prompt",
    MetaKeyword.Negative_prompt: "negative_prompt",
    MetaKeyword.Steps: "steps",
    MetaKeyword.Sampler: "scheduler",
    MetaKeyword.CFG_scale: "cfg_scale",
    MetaKeyword.Seed: "seed",
    MetaKeyword.Model_hash: "Model hash",
    MetaKeyword.Model: "model",
    MetaKeyword.Clipskip: "clip_skip",
    MetaKeyword.ControlNet: "controlnets",
  };
}
