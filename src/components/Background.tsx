export default function Background() {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden">
      <div className="blob" style={{ width: 520, height: 520, top: -160, right: -120, background: "#1fa85a" }} />
      <div className="blob" style={{ width: 460, height: 460, bottom: -180, left: -120, background: "#1f6bff", opacity: 0.22, animationDelay: "-8s" }} />
      <div className="blob" style={{ width: 360, height: 360, top: "45%", left: "55%", background: "#22e06b", opacity: 0.18, animationDelay: "-14s" }} />
      <div
        className="absolute inset-0"
        style={{ background: "radial-gradient(120% 110% at 85% -10%, rgba(34,224,107,0.10), rgba(7,12,9,0) 55%)" }}
      />
    </div>
  );
}
