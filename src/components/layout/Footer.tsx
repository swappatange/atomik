import { Link } from "react-router-dom";
import { Mail, Phone, Linkedin, Twitter, Instagram } from "lucide-react";
import atomikLogo from "@/assets/atomik-logo.png";

const footerLinks = {
  solutions: [
    { name: "Aggregation Platform", path: "/solutions" },
    { name: "Agri-Input Distribution", path: "/solutions" },
    { name: "B2B Partnerships", path: "/partnerships" },
    { name: "Technology", path: "/technology" },
  ],
  company: [
    { name: "About Us", path: "/about" },
    { name: "For Investors", path: "/investors" },
    { name: "Contact", path: "/contact" },
    { name: "Privacy Policy", path: "/privacy" },
  ],
  quickLinks: [
    { name: "Book a Drone Spray", path: "/book" },
    { name: "Join as Drone Pilot", path: "/pilots" },
    { name: "Download App", path: "/download" },
  ],
};

export function Footer() {
  return (
    <footer className="bg-foreground text-background">
      <div className="container py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 lg:gap-8">
          {/* Brand */}
          <div className="lg:col-span-2">
            <Link to="/" className="flex items-center gap-2 mb-4">
              <img src={atomikLogo} alt="Atomik Logo" className="h-[5.625rem] w-auto" />
            </Link>
            <p className="text-background/70 text-sm leading-relaxed mb-6 max-w-sm">
              Precision farming delivered to your field. Connecting farmers with certified drone pilots through a unified platform.
            </p>
            <div className="flex items-center gap-4">
              <a
                href="https://www.linkedin.com/in/swappatange/"
                target="_blank"
                rel="noopener noreferrer"
                className="w-10 h-10 rounded-full bg-background/10 flex items-center justify-center hover:bg-primary transition-colors"
              >
                <Linkedin className="w-5 h-5" />
              </a>
              <a
                href="#"
                className="w-10 h-10 rounded-full bg-background/10 flex items-center justify-center hover:bg-primary transition-colors"
              >
                <Twitter className="w-5 h-5" />
              </a>
              <a
                href="#"
                className="w-10 h-10 rounded-full bg-background/10 flex items-center justify-center hover:bg-primary transition-colors"
              >
                <Instagram className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Solutions */}
          <div>
            <h4 className="font-semibold text-sm uppercase tracking-wider mb-4 text-background/50">Solutions</h4>
            <ul className="space-y-3">
              {footerLinks.solutions.map((link) => (
                <li key={link.name}>
                  <Link
                    to={link.path}
                    className="text-sm text-background/70 hover:text-primary transition-colors"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="font-semibold text-sm uppercase tracking-wider mb-4 text-background/50">Company</h4>
            <ul className="space-y-3">
              {footerLinks.company.map((link) => (
                <li key={link.name}>
                  <Link
                    to={link.path}
                    className="text-sm text-background/70 hover:text-primary transition-colors"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="font-semibold text-sm uppercase tracking-wider mb-4 text-background/50">Quick Links</h4>
            <ul className="space-y-3">
              {footerLinks.quickLinks.map((link) => (
                <li key={link.name}>
                  <Link
                    to={link.path}
                    className="text-sm text-background/70 hover:text-primary transition-colors"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
            <div className="mt-6 space-y-2">
              <a
                href="tel:+917972259718"
                className="flex items-center gap-2 text-sm text-background/70 hover:text-primary transition-colors"
              >
                <Phone className="w-4 h-4" />
                +91 7972259718
              </a>
              <a
                href="mailto:swapnil@atomik.in"
                className="flex items-center gap-2 text-sm text-background/70 hover:text-primary transition-colors"
              >
                <Mail className="w-4 h-4" />
                swapnil@atomik.in
              </a>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="mt-12 pt-8 border-t border-background/10 flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-sm text-background/50">
            Copyright © 2025 Atomik - All Rights Reserved.
          </p>
          <p className="text-sm text-background/50">
            Trusted agri-tech ecosystem for modern India.
          </p>
        </div>
      </div>
    </footer>
  );
}
