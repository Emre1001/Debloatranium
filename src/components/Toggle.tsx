import { motion } from "framer-motion";

export default function Toggle({
  on,
  onClick,
  disabled = false,
}: {
  on: boolean;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={`relative h-7 w-[52px] shrink-0 rounded-full border transition-colors ${
        on
          ? "grad-fill border-transparent"
          : "border-white/10 bg-white/[0.07]"
      } ${disabled ? "cursor-not-allowed opacity-40" : "cursor-pointer"}`}
    >
      <motion.span
        className="absolute top-1 left-1 h-5 w-5 rounded-full bg-white shadow-md"
        animate={{ x: on ? 23 : 0 }}
        transition={{ type: "spring", stiffness: 500, damping: 34 }}
      />
    </button>
  );
}
